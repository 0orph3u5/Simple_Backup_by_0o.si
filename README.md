# Simple_Backup_by_0o.si v1.07

A Bash File for a Simple Backup Solution which uses dd to backup or restore a Partition to/from a .iso but without the empty Storage, and stores it at your backup partition while generating propper Folder and File Name System and it also takes care of mounting the partition

you just need to plug the 2 Hard Drives u want to use and start the Script. then choose wther to Backup or Restore  your file and then enter the name of the partition which should be backuped or restored and then the name of the partition where you store your backups, then decide if you want also to gzip the file. then the script mount the partition to a temporary folder check if there is already folders if not generate Folder "Backup" and sub folder with hostname thengenerate an .iso file without empty storage and in the file name is the partition name and a timestamp.
