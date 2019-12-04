#!/bin/bash
#$ -S /bin/bash

cd /mnt/speed/YOURDIRECTORY #EDIT THIS
source /mnt/speed/yuliam/local/longranger-2.2.2/sourceme.bash
export PATH=/mnt/speed/yuliam/local/jre1.8.0_91/bin:$PATH:/opt/sge625/sge/bin/lx24-amd64/
export SGE_CLUSTER_NAME=ihg-cluster
export _JAVA_OPTIONS="-Djava.io.tmpdir=/mnt/speed/yuliam/tmp"

if [[ $# -ne 1 ]];
    then echo "Usage: program.sh sample_name";
    exit;
fi

dir=fastqs #THIS IS THE DIRECTORY WHERE YOUR FASTQs ARE KEPT (/mnt/speed/YOURDIRECTORY/fastqs)
ID=$1

if [[ ! -d ${dir}/$ID ]];
    then echo "Error: ${dir}/${ID} doesn't exist"
    exit;
fi

longranger wgs --fastqs=${dir}/$ID --id=${ID}_longranger --reference=/mnt/speed/yuliam/reference/refdata-GRCh38-2.1.0_chrM --jobmode=sge --vcmode=gatk:/mnt/speed/yuliam/local/gatk-4.0.4.0/gatk-package-4.0.4.0-local.jar --disable-ui
