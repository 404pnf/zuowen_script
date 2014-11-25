# -*- coding: utf-8 -*-
# helper function
def sanitize_filename str
  return '' if str == nil
  str.gsub(/[ -@\s\n.、()!?,？！，《》（）•^\[\]\/""“‘']/, '_')
    .gsub(/_+/, '_')
    .gsub(/_$/, '')
    .gsub(/^_/, '')
end
def normalize_body_text str
  # 重排文章正文
  # 所有段落顶头
  return "没有内容啊！"   if (str == '' or str.nil?)
  str.gsub(/\t/, " ") # no tabs
    .gsub(/^ +/, "") # 段落开头的空格不要
    .gsub(/\r/, "\n")   # 段落之间有一个空行，先把所有换行替换成两个换行、再删除多余连续换行
    .gsub(/\n/, "\n\n")
    .gsub(/\n\n+/, "\n\n")
end
