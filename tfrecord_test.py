import tensorflow as tf

# Replace with your .tfrecord file path
tfrecord_file = '/home/lucaianniello/Thesis/something-something-v2-train.rgb.tfrecord-00000-of-00128'

# Use tf.data.TFRecordDataset to read the file
raw_dataset = tf.data.TFRecordDataset(tfrecord_file)

# Only look at the first few examples
for raw_record in raw_dataset.take(3):
    example = tf.train.Example()
    example.ParseFromString(raw_record.numpy())
    print(example)
