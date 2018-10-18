require 'rails_helper'

RSpec.describe KnowledgeAreasSynchronizer do
  let(:synchronization) { create(:ieducar_api_synchronization) }
  let(:worker_batch)    { create(:worker_batch) }

  describe "#synchronize!" do

    it "creates knowledge areas" do
      VCR.use_cassette('all_knowledge_areas') do
        described_class.synchronize!(synchronization, worker_batch)

        expect(KnowledgeArea.count).to eq 22
        first = KnowledgeArea.order(:id).first
        expect(first).to have_attributes(
          "description": "ARTES VISUAIS",
          "api_code": "8",
          "sequence": 1
        )
      end
    end

    it "updates knowledge area" do
      VCR.use_cassette('all_knowledge_areas') do
        knowledge_area = create(:knowledge_area,
                                "description": "ARTES",
                                "api_code": "8",
                                "sequence": 2)

        described_class.synchronize!(synchronization, worker_batch)

        expect(KnowledgeArea.count).to eq 22
        expect(knowledge_area.reload).to have_attributes(
          "description": "ARTES VISUAIS",
          "api_code": "8",
          "sequence": 1
        )
      end
    end

  end

end
