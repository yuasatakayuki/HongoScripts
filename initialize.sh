if [ _$hongoscriptsdir = _ ];
then
echo "HongoScripts : initialize.sh error"
echo "declare hongoscriptsdir environmental variable before calling initialize.sh..."
fi

if [ ! -f $HEADAS/headas-init.sh ];
then
echo "HongoScripts : initialize.sh error"
echo "declare HEADAS environmental variable before calling initialize.sh..."
fi

if [ ! -f $CALDB/software/tools/caldbinit.sh ];
then
echo "HongoScripts : initialize.sh error"
echo "declare CALDB environmental variable before calling initialize.sh..."
fi



for d in `ls -d $hongoscriptsdir/*/*/`;
do
dirpath=$d:$dirpath
done

export PATH=$dirpath:$PATH
