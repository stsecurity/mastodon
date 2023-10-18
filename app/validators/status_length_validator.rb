# frozen_string_literal: true

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = 3000
  MAX_UNCUT_CHARS = 500
  URL_PLACEHOLDER_CHARS = 23
  URL_PLACEHOLDER = 'x' * 23

  def validate(status)
    return unless status.local? && !status.reblog?

    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?(status)
    status.errors.add(:text, I18n.t('statuses.over_uncut_character_limit', max: MAX_UNCUT_CHARS)) if too_long_uncut?(status)
  end

  private

  def too_long?(status)
    countable_length(combined_text(status)) > MAX_CHARS
  end

  def too_long_uncut?(status)
    (countable_uncut_length(status) > MAX_UNCUT_CHARS) && (countable_spoiler_length(status) < 1)
  end

  def countable_length(str)
    str.each_grapheme_cluster.size
  end

  def countable_uncut_length(status)
    countable_text(status.text).mb_chars.grapheme_length
  end
  
  def countable_spoiler_length(status)
    status.spoiler_text.mb_chars.grapheme_length
  end

  def combined_text(status)
    [status.spoiler_text, countable_text(status.text)].join
  end

  def countable_text(str)
    return '' if str.blank?

    # To ensure that we only give length concessions to entities that
    # will be correctly parsed during formatting, we go through full
    # entity extraction

    entities = Extractor.remove_overlapping_entities(Extractor.extract_urls_with_indices(str, extract_url_without_protocol: false) + Extractor.extract_mentions_or_lists_with_indices(str))

    rewrite_entities(str, entities) do |entity|
      if entity[:url]
        URL_PLACEHOLDER
      elsif entity[:screen_name]
        "@#{entity[:screen_name].split('@').first}"
      end
    end
  end

  def rewrite_entities(str, entities)
    entities.sort_by! { |entity| entity[:indices].first }
    result = +''

    last_index = entities.reduce(0) do |index, entity|
      result << str[index...entity[:indices].first]
      result << yield(entity)
      entity[:indices].last
    end

    result << str[last_index..]
    result
  end
end
