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
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Enable BETA channel') {
            steps {
                sh('mkdir -p patches-aosp/vendor || true')
                sh('mkdir -p patches-aosp/vendor/tesla-android || true') 
                sh('cp -R jenkins/0001-CI-Disable-release-keys-switch-to-beta-channel.patch patches-aosp/vendor/tesla-android/0001-CI-Disable-release-keys-switch-to-beta-channel.patch') 

            }
        }
        stage('Unfold AOSP repo') {
            steps {
               sh('./unfold_aosp.sh')
           }
        }
        stage('Copy signing keys') {
            steps {
                sh('cp -R /home/jenkins/tesla-android/signing aosptree/vendor/tesla-android/signing')
            }
        }
        stage('Copy SSL certificates') {
            steps {
                sh('cp -R /home/jenkins/tesla-android/certificates aosptree/vendor/tesla-android/services/lighttpd/certificates')
            }
        }
        stage('Compile') {
            steps {
                sh('./build.sh')
            }
        }
        stage('Capture artifacts') {
            steps {
                script {
                    file = readFile('aosptree/vendor/tesla-android/vendor.mk');
                    VERSION = getVersion(file);
                    ARTIFACT_NAME = 'TeslaAndroid-' + VERSION + '-CI-' + getCurrentBranch()  + '-' + getCommitSha() + '-BUILD-' + getBuildNumber() + '-rpi4'
                }
                dir("out") {
                    sh('mv tesla_android_rpi4-ota-' + getBuildNumber() + '.zip ' + ARTIFACT_NAME + '-OTA.zip')
                    sh('mv sdcard.img ' + ARTIFACT_NAME + '-single-image-installer.img')
                    sh('zip ' + ARTIFACT_NAME + '-single-image-installer.img.zip ' + ARTIFACT_NAME + '-single-image-installer.img')
                    archiveArtifacts artifacts: ARTIFACT_NAME + '-single-image-installer.img.zip', fingerprint: true
                    archiveArtifacts artifacts: ARTIFACT_NAME + '-OTA.zip', fingerprint: true
                }
            }
        }
    }
    post {
        success {
            setBuildStatus("Build succeeded", "SUCCESS");
        }
        failure {
            setBuildStatus("Build failed", "FAILURE");
            //cleanWs();
        }
    }
}
