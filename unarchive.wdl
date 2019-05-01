workflow UnArchive {
	String input_tar
	String output_folder
	Boolean? delete_input_tar = false

	call archive_folder {
		input:
			input_tar = input_tar,
			output_folder = output_folder,
			delete_input_tar = delete_input_tar,
	}

	output {
		String outputfile = archive_folder.outputfile
	}
}

task archive_folder {
	String input_tar
	String output_folder
	Boolean delete_input_tar


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

}