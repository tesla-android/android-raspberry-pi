#!/system/bin/sh

first_run=$(getprop persist.tesla_android.nvme_format)
echo ${first_run}
if [ "${first_run}" != "false" ]; then
   # Android won't boot after formatting the NVMe drive during the first boot. A forced reboot is required
   setprop persist.tesla_android.nvme_format false
   reboot
fi
