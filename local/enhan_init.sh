#!/bin/bash

# Copyright 2015 University of Sheffield (Jon Barker, Ricard Marxer)
#                Inria (Emmanuel Vincent)
#                Mitsubishi Electric Research Labs (Shinji Watanabe)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

# This script is made from the kaldi recipe of the 2nd CHiME Challenge Track 2
# made by Chao Weng

. local/path.sh
. local/cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

nj=30
chime3_data=/CDShare/Corpus/CHiME3/

enhan=beamforming
enhan_data=$chime3_data/data/audio/16kHz/enhanced
eval_flag=false # make it true when the evaluation data are released


# process for enhan data
local/real_enhan_chime3_data_prep.sh $enhan $enhan_data || exit 1;
local/simu_enhan_chime3_data_prep.sh $enhan $enhan_data || exit 1;
# make mixed training set from real and simulation training data
# multi = simu + real
utils/combine_data.sh data/tr05_multi_$enhan data/tr05_simu_$enhan data/tr05_real_$enhan
utils/combine_data.sh data/dt05_multi_$enhan data/dt05_simu_$enhan data/dt05_real_$enhan
