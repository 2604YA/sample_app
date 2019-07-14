if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Amazon S3用の設定
      :provider              => 'AWS',
      :region                => ENV['S3_ap-northeast-1'],     # 例: 'ap-northeast-1'
      :aws_access_key_id     => ENV['S3_AKIAV54SNO7CU4G6THWS'],
      :aws_secret_access_key => ENV['S3_zZZsoVVpR+XYnivYtMbmMu18AFe2xQ6pv7HALFyV']
    }
    config.fog_directory     =  ENV['S3_ya426']
  end
end
