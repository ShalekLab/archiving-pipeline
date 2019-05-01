workflow UnArchive {
	String input_tar
	String output_folder
	Boolean? delete_input_tar = false

    String? zones = "us-east1-d us-west1-a us-west1-b us-central1-b"
	Int? num_cpu = 64
	String? memory = "128G"
	Int? disk_space = 1000
	Int? preemptible = 3

	call archive_folder {
		input:
			input_tar = input_tar,
			output_folder = output_folder,
			delete_input_tar = delete_input_tar,
            memory = memory,
			disk_space = disk_space,
			preemptible = preemptible,
			zones = zones,
			num_cpu = num_cpu
	}

	output {
		String outputfile = archive_folder.outputfile
	}
}

task archive_folder {
	String input_tar
	String output_folder
	Boolean delete_input_tar
    	
	String zones
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible

	command {
		
		input_tar_name=`echo ${input_tar} | grep -Eo "[^/]+$"`

		# copy the directory to local disk
		gsutil cp -R ${input_tar} .

		# untar this directory and copy to the new bucket
        mkdir staging
		tar -C staging/ -xzvf $input_tar_name
        gsutil -m cp -R staging/* ${output_folder}
		
		# remove the original directory
		if [ ${delete_input_tar} == "true"]; then
			gsutil rm -f ${input_tar}
		fi
	}

	output {
		String outputfile = "${output_folder}"
	}

	runtime {
		docker: "google/cloud-sdk:244.0.0"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}

}