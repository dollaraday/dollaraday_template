require "savon"
require "securerandom"

# URL: https://api-sandbox.networkforgood.org/PartnerDonationService/DonationServices.asmx
# WSDL: https://api-sandbox.networkforgood.org/PartnerDonationService/DonationServices.asmx?wsdl
module NetworkForGood
  class CreditCard < Base
    SETTINGS = {
      wsdl: NFG[:credit_card_wsdl_url],
      logger: Logger.new("log/savon.log"),
      log: true,
      read_timeout: 120,
      open_timeout: 120,
      adapter: :net_http,
      filters: ["PartnerID", "PartnerPW", "CardNumber", "ExpMonth", "ExpYear", "CSC", "CCSuffix", "CCExpMonth", "CCExpYear"]
    }

    # To access NFG in non-production environments, you can set up script/proxy
    # on your whitelisted IP and proxy requests these SOAP temporarily thru there.
    if CONFIG[:nfg_sandbox_proxy_url] && !(Rails.env.production? or Rails.env.staging?)
      SETTINGS.merge!(proxy: CONFIG[:nfg_sandbox_proxy_url])
    end

    attr_accessor :attributes

    extend Savon::Model

    operations :get_donor_donation_history,
      :get_donor_co_fs,
      :create_cof,
      :make_donation,
      :make_cof_donation,
      :make_donation_add_cof,
      :get_donor_cofs,
      :npo_detail_info,
      :get_fee,
      :delete_donor_cof

    client(SETTINGS)

    def self.soap_actions
      @client.operations
    end

    def self.get_donor_donation_history(donor)
      params = CREDENTIALS.merge({
        "DonorToken" => donor.nfg_donor_token
      })

      resp = super(message: params).to_hash
      handle_response(resp, :get_donor_donation_history_response, :get_donor_donation_history_result)
    end

    def self.get_donor_co_fs(donor)
      params = CREDENTIALS.merge({
        "DonorToken" => donor.nfg_donor_token
      })

      resp = super(message: params).to_hash
      handle_response(resp, :get_donor_co_fs_response, :get_donor_co_fs_result)
    end

    def self.create_cof(donor)
      params = CREDENTIALS.merge extract_donor_params(donor)

      resp  = super(message: params).to_hash
      handle_response(resp, :create_cof_response, :create_cof_result)
    end

    def self.delete_donor_cof(card)
      params = CREDENTIALS.merge({
        "DonorToken" => card.donor.nfg_donor_token,
        "COFId" => card.nfg_cof_id
      })

      resp  = super(message: params).to_hash
      handle_response(resp, :delete_donor_cof_response, :delete_donor_cof_result)
    end

    def self.make_donation(donation)
      total_amount = donation.donor.add_fee? ? (donation.calculate_amount + donation.calculate_added_fee) : donation.calculate_amount

      params = CREDENTIALS.merge({
        "TotalAmount" => total_amount,
        "PartnerTransactionIdentifier" => donation.guid,
        "DonationLineItems" => []
      })
      params.merge! extract_donation_nonprofits_params(donation)
      params.merge! extract_donor_params(donation.donor)

      resp = super(message: params).to_hash
      handle_response(resp, :make_donation_response, :make_donation_result)
    end

    def self.make_cof_donation(donation)
      params = CREDENTIALS.merge({
        "TotalAmount"               => donation.total,
        "PartnerTransactionIdentifier" => donation.guid,
        "DonationLineItems"         => [],
        "COFId"                     => donation.donor.card.nfg_cof_id,
        "DonorIpAddress"            => donation.donor.card.ip_address,
        "DonorToken"                => donation.donor.nfg_donor_token # guid for this user on our side
      })
      params.merge! extract_donation_nonprofits_params(donation)

      resp = super(message: params).to_hash
      handle_response(resp, :make_cof_donation_response, :make_cof_donation_result)
    end

    def self.make_donation_add_cof(donation)
      total_amount = donation.donor.add_fee? ? (donation.calculate_amount + donation.calculate_added_fee) : donation.calculate_amount

      params = CREDENTIALS.merge({
        "TotalAmount" => total_amount,
        "PartnerTransactionIdentifier" => donation.guid
      })
      params.merge! extract_donation_nonprofits_params(donation.nonprofits)
      params.merge! extract_donor_params(donation.donor)

      resp = super(message: params).to_hash
      handle_response(resp, :make_donation_add_cof_response, :make_donation_add_cof_result)
    end

    def self.get_fee(nonprofit)
      params = CREDENTIALS.merge({
        "DonationLineItems" => [],
        "TipAmount" => 0.0,
        "CardType" => "Amex"
      })

      params.merge!({
        "DonationLineItems" => extract_donation_nonprofit_param(nonprofit, 'Add')
      })

      resp = super(message: params).to_hash
      handle_response(resp, :get_fee_response, :get_fee_result)
    end

    # NB: requires a Guidestar agreement
    def self.npo_detail_info(ein)
      params = CREDENTIALS.merge({"NpoEin" => ein})

      resp = super(message: params).to_hash
      handle_response(resp, :npo_detail_info_response, :npo_detail_info_result)
    end

    ##
    ## HELPERS
    ##

    def self.test_get_donor_donation_history
      get_donor_donation_history(Sandbox.get_test_donor)
    end

    def self.test_create_cof
      create_cof(Sandbox.get_test_donor)
    end

    def self.test_delete_cof
      cof = test_create_cof
      donor = Sandbox.get_test_donor
      donor.nfg_donor_token = cof[:donor_token]
      donor.card.nfg_cof_id = cof[:cof_id]

      delete_donor_cof(donor.card)
    end

    def self.test_make_donation
      make_donation(Sandbox.get_test_donation)
    end

    def self.test_make_cof_donation
      cof = test_create_cof
      donation = Sandbox.get_test_donation.tap { |d|
        d.donor.nfg_donor_token = cof[:donor_token]
        d.donor.card.nfg_cof_id = cof[:cof_id]
      }

      make_cof_donation(donation)
    end

    def self.test_make_donation_add_cof
      make_donation_add_cof(Sandbox.get_test_donation)
    end

    ##
    ## HELPERS
    ##

    def self.extract_donor_params(donor)
      {
        "DonorToken"       => donor.nfg_donor_token, # guid for this user on our side
        "DonorIpAddress"   => donor.card.ip_address,
        "DonorEmail"       => donor.card.email,
        "DonorFirstName"   => donor.card.first_name,
        "DonorLastName"    => donor.card.last_name,
        "DonorAddress1"    => donor.card.address1,
        "DonorAddress2"    => donor.card.address2,
        "DonorCity"        => donor.card.city,
        "DonorState"       => donor.card.state,
        "DonorZip"         => donor.card.zip,
        "DonorCountry"     => donor.card.country, # only required for non-US tx, should be ISO Alpha2
        "DonorPhone"       => donor.card.phone,
        "CardType"         => donor.card.card_type,
        "NameOnCard"       => "#{donor.card.first_name} #{donor.card.last_name}",
        "CardNumber"       => donor.card.card_number,
        "ExpMonth"         => donor.card.exp_month,
        "ExpYear"          => donor.card.exp_year,
        "CSC"              => donor.card.csc
      }
    end

    def self.extract_donation_nonprofit_param(nonprofit, add_or_deduct="Deduct")
      {
        "DonationItem"      => {
          "NpoEin"          => nonprofit.ein,
          "Designation"     => "",
          "Dedication"      => "",
          "donorVis"        => "Anonymous",
          "ItemAmount"      => Donation.denomination,
          "RecurType"       => "NotRecurring",
          "AddOrDeduct"     => add_or_deduct,
          "TransactionType" => "Donation"
        }
      }
    end

    def self.extract_donation_nonprofits_params(donation)
      {
        "DonationLineItems" => donation.nonprofits.map do |nonprofit|
          extract_donation_nonprofit_param(nonprofit, donation.donor.add_fee? ? "Add" : "Deduct")
        end
      }
    end
  end
end
