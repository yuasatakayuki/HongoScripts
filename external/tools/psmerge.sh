#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage : psmerge [Output file] [Input file1] [Input file2] ..."
    exit
fi

OutputFile=`echo $1`

if [ -e $1 ]; then
    echo -n "$1 already exits. overwrite $1 [yes]? : "
    read answer
    
    case `echo $answer | tr [A-Z] [a-z]` in
	"" | yes | y ) rm -r $1
	    echo "overwite $1" ;;
	* ) exit ;;
    esac
fi

shift

gs -q -dNOPAUSE -dBATCH -sDEVICE=pswrite -sPAPERSIZE=a4 -sOutputFile=${OutputFile} -c save pop -f $*

exit
