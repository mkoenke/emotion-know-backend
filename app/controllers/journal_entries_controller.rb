require 'uri'
require 'net/http'
require 'openssl'
# require 'rest-client'
# require 'open-uri'
# require 'json'


class JournalEntriesController < ApplicationController
    skip_before_action :authorized, only: [:create, :destroy]
    def index
        journal_entries = JournalEntry.all
        render json: journal_entries
    end

    def show
        journal_entry = JournalEntry.find(params[:id])
        render json: journal_entry
    end

    def create
        journal_entry = JournalEntry.create!(journal_entry_params)

        url = URI("https://twinword-emotion-analysis-v1.p.rapidapi.com/analyze/")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/x-www-form-urlencoded'
        request["x-rapidapi-key"] = ENV['rapidApi_key']
        request["x-rapidapi-host"] = 'twinword-emotion-analysis-v1.p.rapidapi.com'
        request.body = "text=#{journal_entry.content.split(" ").join("%20")}"

        response = http.request(request)
        resp = response.read_body
    #     eval_resp = eval(resp)
    #     # puts eval_resp      
    #    report_1 = Report.create(
    #         title: journal_entry.title,
    #         journal_entry_id: journal_entry.id,
    #         parent_id: journal_entry.child.parent.id,
    #         child_id: journal_entry.child.id,
    #         anger: eval_resp.dig(:emotion_scores, :anger),
    #         disgust: eval_resp.dig(:emotion_scores, :disgust),
    #         fear: eval_resp.dig(:emotion_scores, :fear),
    #         joy: eval_resp.dig(:emotion_scores, :joy),
    #         sadness: eval_resp.dig(:emotion_scores, :sadness),
    #         surprise: eval_resp.dig(:emotion_scores, :surprise),
    #         )
    #     puts report_1
            
        parsed_resp = JSON.parse resp.gsub('=>', ':')
        puts parsed_resp

        inner_hash = parsed_resp["emotion_scores"]
        puts inner_hash

        report_2 = Report.create(
        title: journal_entry.title,
        journal_entry_id: journal_entry.id,
        parent_id: journal_entry.child.parent.id,
        child_id: journal_entry.child.id,
        anger: inner_hash["anger"],
        disgust: inner_hash["disgust"],
        fear: inner_hash["fear"],
        joy: inner_hash["joy"],
        sadness: inner_hash["sadness"],
        surprise: inner_hash["surprise"],
        )
        puts report_2
        render json: journal_entry
    end
    
    def destroy
        journal_entry = JournalEntry.find(params[:id])
        journal_entry.destroy!
        render json: {}
    end

    def update
        journal_entry = JournalEntry.find(params[:id])
        journal_entry.update!(journal_entry_params)
        render json: journal_entry
    end

    private

    def journal_entry_params
        params.permit(:file, :title, :content, :clip, :thumbnail, :child_id)
    end

end
