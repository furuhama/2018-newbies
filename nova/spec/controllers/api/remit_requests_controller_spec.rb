# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RemitRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:target) { create(:user) }
  let(:remit_request) { create(:remit_request, target: user) }

  describe 'GET #index' do
    subject { get :index }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { emails: emails, amount: '3000' } }
    let(:emails) { [target.email] }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      context 'one user' do
        it { is_expected.to have_http_status(:created) }
        it { expect { subject }.to change(RemitRequest, :count).by(1) }
      end

      context 'some users' do
        let(:target2) { create(:user) }
        let(:emails) { [target.email, target2.email] }
        it { is_expected.to have_http_status(:created) }
        it { expect { subject }.to change(RemitRequest, :count).by(2) }
      end
    end
  end

  describe 'POST #accept' do
    subject { post :accept, params: { id: remit_request.id } }
    let(:user) { create(:user) }
    let(:target) { create(:user) }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before do
        login!(user)

        user.balance.update_columns(amount: 1000)
        target.balance.update_columns(amount: 1000)
      end

      let(:remit_request) { create(:remit_request, :outstanding, user: user, target: target, amount: 200) }

      it do
        expect { subject }.to change {
          [user.balance.reload.amount, target.balance.reload.amount]
        }.from([1000, 1000]).to([1200, 800])
      end

      it { is_expected.to have_http_status(:ok) }
    end

    context 'over balance amount' do
      before do
        login!(user)

        user.balance.update_columns(amount: 9_999_000)
        target.balance.update_columns(amount: 50_000)
      end

      let(:remit_request) { create(:remit_request, :outstanding, user: user, target: target, amount: 1_001) }

      it do
        expect(user.balance.reload.amount).to eq 9_999_000
        expect(target.balance.reload.amount).to eq 50_000
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #cancel' do
    subject { post :cancel, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
