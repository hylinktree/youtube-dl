ffdown=${ffdown}
plist=${pllaylist}

begin=1
end=100
step=3

if (( $# > 0 )); then begin=$1; fi
if (( $# > 1 )); then end=$2; fi
if (( $# > 2 )); then step=$3; fi

for((i=$begin;i<$end;i+=$step)); do
        echo $ffdown $plist --playlist-items $i-$(($i+$step)) '&'
done
