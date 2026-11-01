require_relative '../../../test_helper'

class ReelUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'GIANT - The Play', 'GIANT - The Play'
    assert_sanitized 'The Polar Express: Pyjama Party', 'The Polar Express: Pyjama Party'
  end

  def test_subtitled_copies
    assert_sanitized 'Wicker', 'Wicker - Subtitled Screening'
    assert_sanitized 'Wicker', 'Wicker - Subtitled'
  end

  def test_three_d_copies
    assert_sanitized 'Avengers: Doomsday', 'Avengers: Doomsday - 3D'
    assert_sanitized 'Ramayana: Rise of a Legend', 'Ramayana: Rise of a Legend: 3D (Hindi)'
  end

  def test_premium_screen_copies
    assert_sanitized 'Avengers: Doomsday', 'Avengers: Doomsday I Infinity Vision'
  end

  def test_previews
    assert_sanitized 'Dune: Part Three', 'See It First - Dune: Part Three'
  end

  def test_national_theatre_live
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
    assert_sanitized 'National Theatre Live: Golden Boy', 'National Theatre Live: Golden Boy'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: Carmen', 'RBO 2026-2027: Carmen'
    assert_sanitized 'Royal Ballet and Opera: Tosca', 'RBO 2026-27: Tosca'
  end

  def test_anniversaries_and_years
    assert_sanitized 'Rocky', 'Rocky (50th Anniversary)'
    assert_sanitized 'The Evil Dead', 'The Evil Dead (1981)'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, ReelUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
