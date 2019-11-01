#!/bin/bash -v

MARIAN=/fs/snotra0/romang/work/bergamot//marian-dev/build-v187

SRC=et
TRG=en

mkdir -p speed

sacrebleu -t wmt18 -l $SRC-$TRG --echo src > speed/newstest2018.$SRC

echo "### Translating wmt18 $SRC-$TRG on CPU"
$MARIAN/marian-decoder $@ \
    --relative-paths -m model.npz -v vocab.eten.spm vocab.eten.spm \
    -i speed/newstest2018.$SRC -o speed/cpu.newstest2018.$TRG \
    --beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --shortlist lex.s2t 50 50 --optimize --cpu-threads 1 \
    --quiet --quiet-translation --log speed/cpu.newstest2018.log

tail -n1 speed/cpu.newstest2018.log
sacrebleu -t wmt18 -l $SRC-$TRG < speed/cpu.newstest2018.$TRG | tee speed/cpu.newstest2018.$TRG.bleu