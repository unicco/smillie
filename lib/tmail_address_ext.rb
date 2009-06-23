module TMail
  class Mail
    # 指定された名前の最初のヘッダを取得する
    def first_header(key)
      if port.to_s =~ /^#{key}:\s*(.*)/i
        $1
      else
        nil
      end
    end

    def delivered_to
      first_header('delivered-to')
    end

    def return_path
      first_header('return-path').sub(/^</, '').sub(/>$/, '').sub(/^"([^@]+)"@/, '\1@')
    end
  end
end
