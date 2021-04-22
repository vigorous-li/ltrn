PRETRAINED=bert-base-uncased
DATA_DIR=/path/to/parent/dir/of/amazon
DATASET=amazon
EXP_NAME=joint-train-amazon
# if more than one GPU given, first GPU will be for GNN, the rest for BERT
GPU=0,1,2,3
OUTPUT_DIR=/path/to/output

GPU0=$(echo $GPU | awk -F ',' '{print $1}')

# generate initial bert embedding
if [ ! -f ${DATA_DIR}/${DATASET}/train.emb.tsv.gz ]; then
    echo "Generate initial BERT embedding for train dataset!"
    CUDA_VISIBLE_DEVICES=$GPU0 python bert_unsup_embedding.py \
      $DATA_DIR $DATASET $PRETRAINED train
fi
if [ ! -f ${DATA_DIR}/${DATASET}/dev.emb.tsv.gz ]; then
    echo "Generate initial BERT embedding for dev dataset!"
    CUDA_VISIBLE_DEVICES=$GPU0 python bert_unsup_embedding.py \
      $DATA_DIR $DATASET $PRETRAINED dev
fi

python joint_training.py \
 --exp_name $EXP_NAME \
 --gpu $GPU \
 --output_dir $OUTPUT_DIR \
 --master_port 10050 \
 --data_dir $DATA_DIR \
 --dataset $DATASET \
 --bert_model_name_or_path $PRETRAINED \
 --bert_max_steps 2000 \
 --bert_eval_steps 400 \
 --gnn_max_steps 3000 \
 --gnn_eval_steps 100 \
 --overwrite_output_dir \
 --topk 50 \
 --conf_threshold_text 0.5 \
 --cotrain_iter 3
