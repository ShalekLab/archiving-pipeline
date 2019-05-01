workflow Archive {
	String input_folder
	String output_folder
	Boolean? delete_input_folder = false

	call archive_folder {
		input:
			input_folder = input_folder,
			output_folder = output_folder,
			delete_input_folder = delete_input_folder,
	}

	output {
		String outputfile = archive_folder.outputfile
	}
}

task archive_folder {
	String input_folder
	String output_folder
	Boolean delete_input_folder


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

}