class ImageSimilarity
  class Error < StandardError; end
  include PyCall::Import

  CV2 = PyCall.import_module("cv2")
  HASH_TYPES = {
    phash: CV2.img_hash.PHash_create,
    block_mean_zero_hash: CV2.img_hash.BlockMeanHash_create(0),
    marr_hildreth_hash: CV2.img_hash.MarrHildrethHash_create,
    color_moment_hash: CV2.img_hash.ColorMomentHash_create,
  }

  # XXX `unsafe_image_hash` is not thread safe and it has a memory leak. We use
  # `Parallel.map` to run it in another process to work around these problems.
  def self.image_hashes(file)
    Parallel.map([nil], in_processes: 1) do
      attributes = {
        md5: Digest::MD5.file(file).to_s,
        phash: unsafe_image_hash(file, :phash),
        block_mean_zero_hash: unsafe_image_hash(file, :block_mean_zero_hash),
        marr_hildreth_hash: unsafe_image_hash(file, :marr_hildreth_hash),
        color_moment_hash: unsafe_image_hash(file, :color_moment_hash)
      }

      attributes.merge(
        phash_popcount: popcount(attributes[:phash]),
        block_mean_zero_hash_popcount: popcount(attributes[:block_mean_zero_hash]),
        marr_hildreth_hash_popcount: popcount(attributes[:marr_hildreth_hash]),
      )
    end.first
  end

  def self.unsafe_image_hash(file, hash_type)
    image = CV2.imread(file.path)
    hash = HASH_TYPES[hash_type].compute(image)

    hash = hash.tolist.to_a.flatten
    hash = hash.pack("C*") unless hash_type == :color_moment_hash
    hash
  rescue PyCall::PyError => e
    raise Error, "Couldn't compute image hash. Error: (#{e.message})"
  end

  def self.hamming_distance(a, b)
    a_bits = a.unpack("B*").first.split("")
    b_bits = b.unpack("B*").first.split("")

    a_bits.zip(b_bits).map { |a1, b1| a1 != b1 }.count(true)
  end

  def self.hamming_similarity(a, b)
    # 100.0 * (1.0 - (hamming_distance(a, b).to_f / (a.length * 8)))
    100.0 * 2 * (0.5 - (hamming_distance(a, b).to_f / (a.length * 8))).abs
  end

  def self.euclidean_distance(a, b)
    Math.sqrt(a.zip(b).map { |a1, b1| (a1 - b1)**2 }.sum)
  end

  def self.euclidean_similarity(a, b)
    100.0 * (1 - euclidean_distance(a, b))
  end

  def self.popcount(byte_string)
    byte_string.each_byte.map do |byte|
      byte.to_s(2).count("1")
    end
  end
end
