workflow Archive {
	String input_folder
	String output_folder
	Boolean? delete_input_folder = false

	String? zones = "us-east1-d us-west1-a us-west1-b us-central1-b"
	Int? num_cpu = 64
	String? memory = "128G"
	Int? disk_space = 1000
	Int? preemptible = 3

	call archive_folder {
		input:
			input_folder = input_folder,
			output_folder = output_folder,
			delete_input_folder = delete_input_folder,
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
	String input_folder
	String output_folder
	Boolean delete_input_folder
	
	String zones
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible

	command {
		
		input_folder_name=`echo ${input_folder} | grep -Eo "[^/]+$"`

		# copy the directory to local disk
		gsutil cp -R ${input_folder} .
		
		# tar this directory and copy this tarred archive to the new bucket with the storage class set to COLDLINE
		tar -czvf - $input_folder_name | gsutil cp -s COLDLINE - ${output_folder}
		
		# remove the original directory
		if [ ${delete_input_folder} == "true"]; then
			gsutil rm -Rf ${input_folder}
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