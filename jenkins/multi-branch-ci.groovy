def SHARED_WORKSPACE_PATH = "/mnt/bx500/workspaces/tesla_android-rpi4"
def BASE_PATH = "/mnt/bx500/overlays/tesla_android-rpi4"

def getRepoURL() {
    sh "git config --get remote.origin.url > .git/remote-url"
    return readFile(".git/remote-url").trim()
}

def getCommitSha() {
    sh "git rev-parse HEAD > .git/current-commit"
    return readFile(".git/current-commit").trim()
}

def getCurrentBranch() {
    return env.BRANCH_NAME;
}

def getBuildNumber() {
    return env.BUILD_NUMBER;
}

def getVersion(file) {
    def version = file =~ /ro\.tesla-android\.build\.version\s*=\s*([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)/;
    def fullVersion = version[0][0];
    def versionNumber = fullVersion.split('=')[1].trim()
    return versionNumber;
}

void setBuildStatus(String message, String state) {
    repoUrl = getRepoURL();
    commitSha = getCommitSha();
    step([
             $class            : 'GitHubCommitStatusSetter',
             reposSource       : [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
             commitShaSource   : [$class: "ManuallyEnteredShaSource", sha: commitSha],
             errorHandlers     : [[$class: 'ShallowAnyErrorHandler']],
             statusResultSource: [$class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]]]
         ]);
}

pipeline {
    agent { label 'linux' }

    options {
        buildDiscarder(logRotator(artifactNumToKeepStr: '5', artifactDaysToKeepStr:'90'))
    }

    stages {
        stage('Setup OverlayFS') {
            steps {
                script {
                    if (getCurrentBranch() == 'develop') {
                        sh "mkdir -p ${SHARED_WORKSPACE_PATH} ${BASE_PATH}/merged"
                        sh """
                            if ! mountpoint -q ${BASE_PATH}/merged; then
                        		sudo mount --bind ${SHARED_WORKSPACE_PATH} ${BASE_PATH}/merged
                            fi
                        """
                    } else {
                        sh "mkdir -p ${BASE_PATH}/upper ${BASE_PATH}/work ${BASE_PATH}/merged"
                        sh """
                            if ! mountpoint -q ${BASE_PATH}/merged; then
                                sudo mount -t overlay overlay -olowerdir=${SHARED_WORKSPACE_PATH},upperdir=${BASE_PATH}/upper,workdir=${BASE_PATH}/work ${BASE_PATH}/merged
                            fi
                        """
                    }
                }
            }
        }
        stage('Checkout') {
            steps {
                dir("${BASE_PATH}/merged") {
                    checkout scm
                }
            }
        }
        stage('Enable BETA channel') {
            steps {
                dir("${BASE_PATH}/merged") {
                    sh '''
                        mkdir -p patches-aosp/vendor || true
                        mkdir -p patches-aosp/vendor/tesla-android || true
                        cp -R jenkins/0001-Switch-to-beta-channel.patch patches-aosp/vendor/tesla-android/0001-Switch-to-beta-channel.patch
                    '''
                }
            }
        }
        stage('Unfold AOSP repo') {
            steps {
                dir("${BASE_PATH}/merged") {
                    sh './unfold_aosp.sh'
                }
            }
        }
        stage('Copy signing keys') {
            steps {
                dir("${BASE_PATH}/merged") {
                    sh 'cp -R /home/jenkins/tesla-android/signing aosptree/vendor/tesla-android/signing'
                    sh 'cp -R aosptree/vendor/tesla-android/signing/releasekey.pk8 aosptree/build/make/target/product/security/testkey.pk8'
                    sh 'cp -R aosptree/vendor/tesla-android/signing/releasekey.x509.pem aosptree/build/make/target/product/security/testkey.x509.pem'
                }
            }
        }
        stage('Copy SSL certificates') {
            steps {
                dir("${BASE_PATH}/merged") {
                    sh 'cp -R /home/jenkins/tesla-android/certificates aosptree/vendor/tesla-android/services/lighttpd/certificates'
                }
            }
        }
        stage('Compile RPI4') {
            steps {
                dir("${BASE_PATH}/merged") {
                    sh './build_rpi4.sh'
                }
            }
        }
        stage('Capture artifacts RPI4') {
            steps {
                script {
                    file = readFile("${BASE_PATH}/merged/aosptree/vendor/tesla-android/vendor.mk");
                    VERSION = getVersion(file);
                    ARTIFACT_NAME = 'TeslaAndroid-' + VERSION + '-CI-' + getCurrentBranch()  + '-' + getCommitSha() + '-BUILD-' + getBuildNumber() + '-rpi4'
                }
                dir("${BASE_PATH}/merged/out") {
                    sh """
                        mv tesla_android_rpi4-ota-${env.BUILD_NUMBER}.zip ${ARTIFACT_NAME}-OTA.zip
                        mv sdcard.img ${ARTIFACT_NAME}-single-image-installer.img
                        zip ${ARTIFACT_NAME}-single-image-installer.img.zip ${ARTIFACT_NAME}-single-image-installer.img
                    """
                    archiveArtifacts artifacts: "${ARTIFACT_NAME}-single-image-installer.img.zip", fingerprint: true
                    archiveArtifacts artifacts: "${ARTIFACT_NAME}-OTA.zip", fingerprint: true
                }
            }
        }
        stage('Remove artifacts') {
            steps {
                dir("${BASE_PATH}/merged/out") {
                    sh '''
                        rm -f *.img
                        rm -f *.zip
                    '''
                }
            }
        }
    }
    post {
	    success {
	        script {
	            setBuildStatus("Build succeeded", "SUCCESS");
	                sh "sudo umount -l ${BASE_PATH}/merged"
	            if (getCurrentBranch() != 'main') {
	                sh "sudo rm -rf ${BASE_PATH}/upper ${BASE_PATH}/work"
	            }
	        }
	    }
	    failure {
	        script {
	            setBuildStatus("Build failed", "FAILURE");
	            //if (getCurrentBranch() == 'develop') {
	            //    sh "sudo umount -l ${BASE_PATH}/merged"
	            //    sh "sudo rm -rf ${SHARED_WORKSPACE_PATH}"
	            //} else {
	            //    sh "sudo umount -l ${BASE_PATH}/merged"
	            //    sh "sudo rm -rf ${BASE_PATH}/upper ${BASE_PATH}/work"
	            //}
	        }
	    }
      }
}
