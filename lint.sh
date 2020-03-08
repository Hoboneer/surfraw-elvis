#!/bin/sh
# Analyse output of `opts.sh` (from stdin), printing statistics and warnings.
num_arg_opts=0
num_flag_opts=0
IFS=:
while read elvis opts; do
	IFS=' '
	clean_elvis_name="$(basename -s .elvis "$elvis")"
	uses_type_opt=no
	uses_search_opt=no
	for opt_with_aliases in $opts; do
		IFS=,
		for opt in $opt_with_aliases; do
			# Check for specific options
			case "$opt" in
				-search=*) uses_search_opt=yes ;;
				-type=*) uses_type_opt=yes ;;
			esac
			# Count options
			case "$opt" in
				-*=*) num_arg_opts="$(( num_arg_opts + 1 ))" ;;
				-*) num_flag_opts="$(( num_flag_opts + 1 ))" ;;
			esac
		done
		IFS=' '
	done
	case "$uses_type_opt:$uses_search_opt" in
		yes:no)
			printf "warning: elvis '%s' has a -type= option but no -search= option\n" "$clean_elvis_name"
			;;
	esac
	IFS=:
done
printf "Statistics:\n"
printf "\tnumber of options with arguments: %d\n" $num_arg_opts
printf "\tnumber of flag options (options with no arguments): %d\n" $num_flag_opts
