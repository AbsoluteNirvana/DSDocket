# Redmine - project management software
# Copyright (C) 2006-2011  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../../../../test_helper', __FILE__)

class PdfTest < ActiveSupport::TestCase
  include Redmine::I18n

  def test_fix_text_encoding_nil
    set_language_if_valid 'ja'
    pdf = Redmine::Export::PDF::IFPDF.new('ja')
    assert pdf
    assert_equal '', pdf.fix_text_encoding(nil)
  end

  def test_fix_text_encoding_backslash_ascii
    set_language_if_valid 'ja'
    pdf = Redmine::Export::PDF::IFPDF.new('ja')
    assert pdf
    assert_equal '\\\\abcd', pdf.fix_text_encoding('\\abcd')
    assert_equal 'abcd\\\\', pdf.fix_text_encoding('abcd\\')
    assert_equal 'ab\\\\cd', pdf.fix_text_encoding('ab\\cd')
    assert_equal '\\\\abcd\\\\', pdf.fix_text_encoding('\\abcd\\')
    assert_equal '\\\\abcd\\\\abcd\\\\',
                 pdf.fix_text_encoding('\\abcd\\abcd\\')
  end

  def test_fix_text_encoding_double_backslash_ascii
    set_language_if_valid 'ja'
    pdf = Redmine::Export::PDF::IFPDF.new('ja')
    assert pdf
    assert_equal '\\\\\\\\abcd', pdf.fix_text_encoding('\\\\abcd')
    assert_equal 'abcd\\\\\\\\', pdf.fix_text_encoding('abcd\\\\')
    assert_equal 'ab\\\\\\\\cd', pdf.fix_text_encoding('ab\\\\cd')
    assert_equal 'ab\\\\\\\\cd\\\\de', pdf.fix_text_encoding('ab\\\\cd\\de')
    assert_equal '\\\\\\\\abcd\\\\\\\\', pdf.fix_text_encoding('\\\\abcd\\\\')
    assert_equal '\\\\\\\\abcd\\\\\\\\abcd\\\\\\\\',
                 pdf.fix_text_encoding('\\\\abcd\\\\abcd\\\\')
  end

  def test_fix_text_encoding_backslash_ja_cp932
    pdf = Redmine::Export::PDF::IFPDF.new('ja')
    assert pdf
    assert_equal "\x83\\\\\x98A",
                  pdf.fix_text_encoding("\xe3\x82\xbd\xe9\x80\xa3")
    assert_equal "\x83\\\\\x98A\x91\xe3\x95\\\\",
                  pdf.fix_text_encoding("\xe3\x82\xbd\xe9\x80\xa3\xe4\xbb\xa3\xe8\xa1\xa8")
    assert_equal "\x91\xe3\x95\\\\\\\\",
                  pdf.fix_text_encoding("\xe4\xbb\xa3\xe8\xa1\xa8\\")
    assert_equal "\x91\xe3\x95\\\\\\\\\\\\",
                  pdf.fix_text_encoding("\xe4\xbb\xa3\xe8\xa1\xa8\\\\")
    assert_equal "\x91\xe3\x95\\\\a\\\\",
                  pdf.fix_text_encoding("\xe4\xbb\xa3\xe8\xa1\xa8a\\")
  end

  def test_fix_text_encoding_cannot_convert_ja_cp932
    pdf = Redmine::Export::PDF::IFPDF.new('ja')
    assert pdf
    utf8_txt_1  = "\xe7\x8b\x80\xe6\x85\x8b"
    utf8_txt_2  = "\xe7\x8b\x80\xe6\x85\x8b\xe7\x8b\x80"
    utf8_txt_3  = "\xe7\x8b\x80\xe7\x8b\x80\xe6\x85\x8b\xe7\x8b\x80"
    if utf8_txt_1.respond_to?(:force_encoding)
      assert_equal "?\x91\xd4",
                   pdf.fix_text_encoding(utf8_txt_1)
      assert_equal "?\x91\xd4?",
                   pdf.fix_text_encoding(utf8_txt_2)
      assert_equal "??\x91\xd4?",
                   pdf.fix_text_encoding(utf8_txt_3)
    else
      assert_equal "???\x91\xd4",
                   pdf.fix_text_encoding(utf8_txt_1)
      assert_equal "???\x91\xd4???",
                   pdf.fix_text_encoding(utf8_txt_2)
      assert_equal "??????\x91\xd4???",
                   pdf.fix_text_encoding(utf8_txt_3)
    end
  end
end
