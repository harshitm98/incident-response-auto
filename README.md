# Incidient Response automation

This simple script aims to automate early stages of an incident response for Linux based systems. This works for both live systems or if you have a Linux drive mounted on your system.


## Usage
Run the script using bash as a root user:
```bash
$ ./auto.sh [-o OUTPUT_DIR -m MOUNT_LOCATION]
```

Example: 
```bash
$ ./auto.sh -o auto_script_output
$ ./auto.sh -o auto_script_output -m /mnt/mydisk # if you have a disk mounted at /mnt/mydisk
```

**For Python script report_generator.py**

Upload to output of the script to automatically generate a report on Notion:
```bash
$ ./report_generator.py -f <Input folder location> -t <Report Title>
$ ./report_generator.py -f auto_script_output -t "My Incidient Response"
```


