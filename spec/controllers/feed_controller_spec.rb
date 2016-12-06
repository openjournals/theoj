require "rails_helper"

describe FeedController do

  describe 'GET #arxiv' do

    let(:a_date) { Time.new(2015, 1, 2, 12, 4, 5) }

    def create_paper(attributes={})
      attributes = {
          state:         'published',
          provider_type: 'arxiv',
          created_at:     a_date
      }.merge(attributes)
      create(:paper, attributes)
    end

    before do
      allow(controller).to receive(:render).and_call_original
    end

    def expect_papers(expected)
      expect(controller).to have_received(:render) do |name, options|
        expect(options[:locals][:papers]).to eq(expected)
      end
    end

    it 'should return xml' do
      get :arxiv, format: 'xml'

      expect(response).to             have_http_status(:ok)
      expect(response.content_type).to eq 'application/xml'
      expect(response).to              render_template('arxiv')
    end

    it 'should include a list of paper attributes' do
      create_paper(doi:'doi-01', provider_id:'0000.0001')
      create_paper(doi:'doi-02', provider_id:'0000.0002')
      create_paper(doi:'doi-03', provider_id:'0000.0003')

      get :arxiv, format: 'xml'

      expect_papers [
                        { preprint_id: 'arXiv:0000.0001',
                          doi:         'doi-01',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' },
                        { preprint_id: 'arXiv:0000.0002',
                          doi:         'doi-02',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' },
                        { preprint_id: 'arXiv:0000.0003',
                          doi:         'doi-03',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' }
                    ]
    end

    it 'should only include published papers' do
      create_paper(doi:'doi-01', provider_id:'0000.0001')
      create_paper(doi:'doi-02', provider_id:'0000.0002', state:'accepted')
      create_paper(doi:'doi-03', provider_id:'0000.0003')

      get :arxiv, format: 'xml'

      expect_papers [
                        { preprint_id: 'arXiv:0000.0001',
                          doi:         'doi-01',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' },
                        { preprint_id: 'arXiv:0000.0003',
                          doi:         'doi-03',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' }
                    ]
    end

    it 'should only include Arxiv papers' do
      create_paper(doi:'doi-01', provider_id:'0000.0001')
      create_paper(doi:'doi-02', provider_id:'0000.0002', provider_type:'test')
      create_paper(doi:'doi-03', provider_id:'0000.0003')

      get :arxiv, format: 'xml'

      expect_papers [
                        { preprint_id: 'arXiv:0000.0001',
                          doi:         'doi-01',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' },
                        { preprint_id: 'arXiv:0000.0003',
                          doi:         'doi-03',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' }
                    ]
    end

    it 'should only recent papers' do
      create_paper(doi:'doi-01', provider_id:'0000.0001', updated_at: Time.now)
      create_paper(doi:'doi-02', provider_id:'0000.0002', updated_at: 3.months.ago - 1.day)
      create_paper(doi:'doi-03', provider_id:'0000.0003', updated_at: 3.months.ago)

      get :arxiv, format: 'xml'

      expect_papers [
                        { preprint_id: 'arXiv:0000.0001',
                          doi:         'doi-01',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' },
                        { preprint_id: 'arXiv:0000.0003',
                          doi:         'doi-03',
                          journal_ref: 'The Open Journal of Astrophysics, 2015' }
                    ]
    end

  end

end
