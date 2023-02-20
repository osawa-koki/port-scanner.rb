require 'socket'
require 'timeout'

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

# スキャン対象のIPアドレスを設定
ip_address = "github.com"

# スキャン対象のポート範囲を指定
port_from = 80
port_to = 100

# スレッドの数を指定
thread_count = 10

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
        port_result = port_open?(ip_address, port_number)
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
