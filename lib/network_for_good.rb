module NetworkForGood
  class Base
    class Error < StandardError
      attr_reader :response
      def initialize(response)
        @response = response
      end
      def message
        @response.values.join(" - ") rescue @response.to_s
      end
    end
    class UnexpectedResponse < Error; end
    class ChargeFailed < Error; end
    class InvalidEIN < Error; end
    class OtherError < Error; end

    CREDENTIALS = {
      "PartnerID"        => NFG[:id],      
      "PartnerPW"        => NFG[:password],
      "PartnerSource"    => NFG[:source],  
      "PartnerCampaign"  => NFG[:campaign] 
    }

    def self.handle_response(response, key1, key2)
      body = response[key1][key2]
      log_for_dev(body)

      case body[:status_code]
      when "Success", nil
        body
      when "ValidationFailed"
        # TODO notify us here
        Array.wrap(body[:error_details][:error_info]) # eg [{:err_code=>"InvalidDonorIpAddres", :err_data=>"The Donor IP addres \"\" is invalid."}]
      when "ChargeFailed"
        # TODO notify us here
        raise NetworkForGood::Base::ChargeFailed.new(body)
      when "InvalidEIN" # for npo_detail_info
        raise NetworkForGood::Base::InvalidEIN.new(body)
      when "OtherError"
        raise NetworkForGood::Base::OtherError.new(body)
      else
        raise NetworkForGood::Base::UnexpectedResponse.new(body)
      end
    end

    def self.log_for_dev(resp)
      if Rails.env == "development"
        Rails.logger.info(resp)
      end
    end

  end

end
