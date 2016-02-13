# デ辞蔵 SOAP版APIを使って複数辞書を横断検索
# https://dejizo.jp/dev/soap.html

require 'savon'

search_word = ARGV[0] || ''

client = Savon.client do
  wsdl 'http://public.dejizo.jp/SoapServiceV11.asmx?WSDL'
  # デフォルトではlowerCamelcaseに変換されるので無効化
  convert_request_keys_to :none
  # デバッグ用の設定
  log_level :debug
  log true
  pretty_print_xml true
end

# 使用可能なoperationリスト
p client.operations
# => [:get_dic_list, :search_dic_item, :get_exact_words, :get_dic_item, :get_item_map_nodes]

# 辞書リストの取得
get_dic_list_response = client.call(:get_dic_list)
dic_list = get_dic_list_response.body[:get_dic_list_response][:get_dic_list_result][:dic_info]

# 検索対象の辞書
dic_id_list = [
  {
    guid: [
      dic_list[1][:dic_id], # EJDict英和辞典
      dic_list[8][:dic_id], # フリー百科辞典 ウィキペディア日本語
      dic_list[9][:dic_id], # 三省堂 デイリーコンサイス英和辞典（試用版）
    ]
  }
]
# 検索クエリ
query_list = [
  {
    Query: {
      Words: search_word,
      ScopeID: 'HEADWORD',
      MatchOption: 'CONTAIN',
      MergeOption: 'AND'
    }
  }
]
message = {
  AuthTicket: '',
  DicIDList: dic_id_list,
  QueryList: query_list,
  ItemStartIndex: 0,
  ItemCount: 20,
  CompleteItemCount: 0
}
search_dic_item_response = client.call(:search_dic_item, message: message)
