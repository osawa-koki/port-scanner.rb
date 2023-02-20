require 'socket'
require 'timeout'
require 'yaml'

# 設定ファイルの読み込み
config = YAML.load_file('./config.yaml')['config']
host = config['host']
port_from = config['port_from'].to_i
port_to = config['port_to'].to_i
thread_count = config['thread_count'].to_i
timeout = config['timeout'].to_i

def port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      s = TCPSocket.new(ip, port)
      s.close
    end
    { port => true }
  rescue Timeout::Error, Errno::ETIMEDOUT
    { port => false }
  end
end

# Mutexオブジェクトを作成
mutex = Mutex.new

# スレッドを使用してポートスキャンを実行し、結果をハッシュに追加
ports_results = {}
threads = []
(1..thread_count).each do
  threads << Thread.new do
    begin
      while true do
        port_number = nil
        mutex.synchronize do
          port_number = port_from
          port_from += 1
        end
        break if port_number > port_to
        port_result = port_open?(host, port_number)
        mutex.synchronize do
          ports_results.merge!(port_result)
        end
      end
    rescue ThreadError
    end
  end
end

threads.each { |t| t.join }

# ポート番号と結果を表示
ports_results.each do |port, result|
  if result
    puts "ポート #{port} は開いています。"
  else
    puts "ポート #{port} は閉じています。"
  end
end
