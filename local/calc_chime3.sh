#!/bin/bash

#  Copyright  2015  Mitsubishi Electric Research Laboratories (Author: Shinji Watanabe)
#  Apache 2.0.


if [ $# -ne 2 ]; then
    printf "\nUSAGE: %s <decoded dir> <lm>\n\n" `basename $0`
    # printf "\nUSAGE: %s <training experiment directory> <enhance method> <lm>\n\n" `basename $0`
    printf "%s exp/tri3b_tr05_sr_noisy noisy\n\n" `basename $0`
    exit 1;
fi

# echo "$0 $@"  # Print the command line for logging

eval_flag=false # make it true when the evaluation data are released
dir=$1
# enhan=$2
lm=${2-"tgpr"}
# echo "compute WER for each location"
# echo ""
for a in `find $dir/ | grep "\/wer_" | awk -F'[/]' '{print $NF}' | sort`; do
    echo -n "$a "
    cat $dir/$a | grep WER | awk '{err+=$4} {wrd+=$6} END{printf("%.2f\n",err/wrd*100)}'
done| sort -k 2 | head -n 1 > $dir/best_wer

lmw=`cut -f 1 -d" " $dir/best_wer | cut -f 2 -d"_"`
# echo "-------------------"
# printf "best overall WER %s" `cut -f 2 -d" " $dir/log/best_wer_$enhan`
# echo -n "%"
# printf " (language model weight = %s)\n" $lmw
# echo "-------------------"
# for task in simu real; do
# rdir=$dir/decode_${lm}_#dt05_${task}_$enhan
# lmw=9
rdir=$dir
for a in _BUS _CAF _PED _STR; do
	grep $a $rdir/scoring/test_filt.txt \
	    > $rdir/scoring/test_filt_$a.txt
	cat $rdir/scoring/$lmw.tra \
	    | utils/int2sym.pl -f 2- $rdir/../graph_${lm}_5k/words.txt \
	    | sed s:\<UNK\>::g \
	    | compute-wer --text --mode=present ark:$rdir/scoring/test_filt_$a.txt ark,p:- \
	    1> $rdir/${a}_wer_$lmw 2> /dev/null
    echo "${a/_/} `grep WER $rdir/${a}_wer_$lmw | cut -f 2 -d" "`"
done
echo "Average `grep WER $rdir/wer_$lmw | cut -f 2 -d" "`"
# grep WER $rdir/wer_$lmw | cut -f 2 -d" "
# echo -n "$task WER: `grep WER $rdir/wer_$lmw | cut -f 2 -d" "`% (Average), "
# echo -n "`grep WER $rdir/_BUS_wer_$lmw | cut -f 2 -d" "`% (BUS), "
# echo -n "`grep WER $rdir/_CAF_wer_$lmw | cut -f 2 -d" "`% (CAFE), "
# echo -n "`grep WER $rdir/_PED_wer_$lmw | cut -f 2 -d" "`% (PEDESTRIAN), "
# echo -n "`grep WER $rdir/_STR_wer_$lmw | cut -f 2 -d" "`% (STREET)"
# echo ""
# echo "-------------------"
# done
# for spreadsheet cut&paste
# for task in simu real; do
# rdir=$dir/decode_${lm}_#dt05_${task}_$enhan
# rdir=$dir
# grep WER $rdir/_BUS_wer_$lmw | cut -f 2 -d" "
# grep WER $rdir/_CAF_wer_$lmw | cut -f 2 -d" "
# grep WER $rdir/_PED_wer_$lmw | cut -f 2 -d" "
# grep WER $rdir/_STR_wer_$lmw | cut -f 2 -d" "
# grep WER $rdir/wer_$lmw | cut -f 2 -d" "
# done
# cut -f 2 -d" " $dir/log/best_wer_$enhan
# echo $lmw

