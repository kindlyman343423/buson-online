class Article < ApplicationRecord
  enum status: { is_private: 0, is_public: 10 }

  validates :title, presence: true
  validates :status, presence: true

  has_one_attached :thumbnail # Rails6からfilesをupdateするとき、過去fileは削除され、新たにfileがattachされる。replaceの動作になる。

  def simple_format
    {
      id: id,
      status: status,
      title: title,
      thumbnail_url: thumbnail.url,
      created_at: created_at
    }.compact
  end

  def detail_format
    simple_format.merge({
      content: content,
    })
  end
end
