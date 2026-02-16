#!/bin/bash

declare Host='http://10.11.99.1'

function run_curl() {
	if ! curl --silent "$@"; then
		echo -e \
			"Curl failed.\n" \
			"\tExpecting Remarkable device to be routable as: ${Host##*/}\n" \
			"\tIs the web interface enabled on the device?\n\n" \
			>&2
		exit 91
	fi
}

function handle_run_mode_list() {
	## Note: When an invalid folder guid is specified, the A.P.I. will return results for the document root.
	local parent_folder_guid="$1"

	local Documents="$Host/documents"
	## Note: Trailing slash is necessary if parent_folder_guid is empty.
	local -a curl_args=(
		"$Documents/$parent_folder_guid"
	)
	run_curl "${curl_args[@]}" | jq -r 'map({(.ID): {VissibleName,Type}}) | add'
	## Note:
	## 	"Vissible" is not a typo, despite the metadata file key displaying as "visible"...
	## 	This particular capitalisation is required, despite not matching the capitalisation used in the metadata files.
}
function handle_run_mode_get() {
	local target_guid="$1"
	local target_file_extension=	## $2

	if [[ -z "$1" || -z "$2" ]]; then
		echo 'Invocation of `get` requires subsequent arguments for the (1) target G.U.I.D. and then (2) desired file extension.' >&2
		return 1
	fi

	local -a KnownValidExtensions=(
		'pdf'
		'rmdoc'	## Raw notebook archive.
		## epubs are only supported for upload; not download!
	)
	for i in "${KnownValidExtensions[@]}"; do
		if [[ "${2,,}" == "$i" ]]; then
			target_file_extension="$i"
			break
		fi
	done
	if [[ -z "$target_file_extension" ]]; then
		echo "Invalid target file extension: \"$2\"" >&2
		return 1
	fi

	local lwd="$PWD"	## To do: adjust as needed to download remote folder structure.
	local download_file="$lwd/$target_guid.$target_file_extension"
	if [[ -a "$download_file" ]]; then
		echo "File already exists at destination: \"$download_file\"" >&2
		return 2
	fi
	local Download="$Host/download"
	local -a curl_args=(
		"$Download/$target_guid/$target_file_extension"
		'-o' "$download_file"
	)
	run_curl "${curl_args[@]}"
}
function handle_run_mode_put() {
	## Note: files can only be uploaded to the most recently listed folder.
	local target_file="$1"
	if [[ ! -f "$target_file" ]]; then
		echo "Specified target is not a file: \"$target_file\"" >&2
		return 1
	fi

	local -i file_extension_is_valid=0
	local target_file_extension="${1##*.}"
	if [[ -z "$target_file_extension" ]]; then
		echo "Target file's name has no extension." >&2
		return 1
	fi
	local -a KnownValidExtensions=(
		'pdf'
		'epub'
	)
	for i in "${KnownValidExtensions[@]}"; do
		if [[ "${target_file_extension,,}" == "$i" ]]; then
			file_extension_is_valid=1
			break
		fi
	done
	if ! ((file_extension_is_valid)); then
		echo "Invalid target file extension: \"$target_file_extension\"" >&2
		return 1
	fi

	local Upload="$Host/upload"
	local -a curl_args=(
		"$Upload"
		"-H 'Origin: $Host'"
		"-H 'Accept: */*'"
		"-H 'Referer: $Host/'"
		"-H 'Connection: keep-alive'"
		'-F' "file=@$target_file;filename=$(basename "$target_file");type=$(file --brief --mime-type "$target_file")"
	)
	run_curl "${curl_args[@]}"
}
#function handle_run_mode_rename() {
#function make_folder() {
#	## https://github.com/splitbrain/ReMarkableAPI/blob/3d6cbe9ac660e50d78f9e5d68a30de9d42981d6d/src/RemarkableAPI.php#L182
#}
#function handle_run_mode_move() {
#function handle_run_mode_delete() {	## Not yet functional!
#	## https://github.com/splitbrain/ReMarkableAPI/blob/3d6cbe9ac660e50d78f9e5d68a30de9d42981d6d/src/RemarkableAPI.php#L306
#	## Implementation below seems to list the document root folder.
#	## 	Posting to Search="$Host/documents/search" in function below produced the same result.
#	## 	Probably the default for invalid sub-paths to "$Host/documents".
#	local target_guid="$1"
#	local Delete="$Host/documents/delete"
#	local -a curl_args=(
#		'-X' 'PUT'
#		#'-X' 'POST'
#		"$Delete/$1"
#	)
#	run_curl "${curl_args[@]}"
#}
function handle_run_mode_search() {	## Not yet functional!
	## https://remarkable.guide/tech/usb-web-interface.html#post-http-10-11-99-1-search-keyword
	## Implementation below returns an empty array.
	local search_term="$1"
	if [[ -z "$search_term" ]]; then
		echo "No search term was provided." >&2
		return 1
	fi

	local Search="$Host/search"
	local -a curl_args=(
		'-X' 'POST'
		'--variable' "path='$search_term'"	## Percent encode.
		'--expand-url' "$Search/{{path:url}}"
	)
	run_curl "${curl_args[@]}"
	#| jq -r 'map({(.ID): {VissibleName,Type}}) | add'
}


case ${1,,} in
	list)    shift; handle_run_mode_list    "$@" ;;
	get)     shift; handle_run_mode_get     "$@" ;;
	put)     shift; handle_run_mode_put     "$@" ;;
	search)  shift; handle_run_mode_search  "$@" ;;
	*)
		echo "Invalid run mode: \"$1\"" >&2
		exit
esac

