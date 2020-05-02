require 'rails_helper'

describe '投稿のテスト' do
  let!(:book) { create(:book,title:'hoge',body:'body') }
  describe 'トップ画面(root_path)のテスト' do
    before do 
      visit root_path
    end
    context '表示の確認' do
      it 'トップ画面(root_path)に一覧ページへのリンクが表示されているか' do
        expect(page).to have_link "", href: books_path
      end
      it 'root_pathが"/"であるか' do
        expect(current_path).to eq('/')
      end
    end
  end
  describe "一覧画面のテスト" do
    before do
      visit books_path
    end
    context '一覧の表示とリンクの確認' do
      it "bookの一覧表示(tableタグ)と投稿フォームが同一画面に表示されているか" do
        expect(page).to have_selector 'table'
        expect(page).to have_field 'book[title]'
        expect(page).to have_field 'book[body]'
      end
      it "bookのタイトルと感想を表示し、詳細・編集・削除のリンクが表示されているか" do
          (1..5).each do |i|
            Book.create(title:'hoge'+i.to_s,body:'body'+i.to_s)
          end
          visit books_path
          Book.all.each_with_index do |book,i|
            j = i * 3
            expect(page).to have_content book.title
            expect(page).to have_content book.body
            # Showリンク
            show_link = find_all('a')[j]
            expect(show_link.native.inner_text).to match(/show/i)
            expect(show_link[:href]).to eq book_path(book)
            # Editリンク
            show_link = find_all('a')[j+1]
            expect(show_link.native.inner_text).to match(/edit/i)
            expect(show_link[:href]).to eq edit_book_path(book)
            # Destroyリンク
            show_link = find_all('a')[j+2]
            expect(show_link.native.inner_text).to match(/destroy/i)
            expect(show_link[:href]).to eq book_path(book)
          end
      end
      it 'Create Bookボタンが表示される' do
        expect(page).to have_button 'Create Book'
      end
    end
    context '投稿処理に関するテスト' do
      it '投稿に成功しサクセスメッセージが表示されるか' do
        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
        click_button 'Create Book'
        expect(page).to have_content 'successfully'
      end
      it '投稿に失敗する' do
        click_button 'Create Book'
        expect(page).to have_content 'error'
        expect(current_path).to eq('/books')
      end
      it '投稿後のリダイレクト先は正しいか' do
        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
        click_button 'Create Book'
        expect(page).to have_current_path book_path(Book.last)
      end
    end
    context 'book削除のテスト' do
      it 'bookの削除' do
        expect{ book.destroy }.to change{ Book.count }.by(-1)
        # ※本来はダイアログのテストまで行うがココではデータが削除されることだけをテスト
      end
    end
  end
  describe '詳細画面のテスト' do
    before do
      visit book_path(book)
    end
    context '表示の確認' do
      it '本のタイトルと感想が画面に表示されていること' do
        expect(page).to have_content book.title
        expect(page).to have_content book.body
      end
      it 'Editリンクが表示される' do
        edit_link = find_all('a')[0]
        expect(edit_link.native.inner_text).to match(/edit/i)
			end
      it 'Backリンクが表示される' do
        back_link = find_all('a')[1]
        expect(back_link.native.inner_text).to match(/back/i)
			end  
    end
    context 'リンクの遷移先の確認' do
      it 'Editの遷移先は編集画面か' do
        edit_link = find_all('a')[0]
        edit_link.click
        expect(current_path).to eq('/books/' + book.id.to_s + '/edit')
      end
      it 'Backの遷移先は一覧画面か' do
        back_link = find_all('a')[1]
        back_link.click
        expect(page).to have_current_path books_path
      end
    end
  end
  describe '編集画面のテスト' do
    before do
      visit edit_book_path(book)
    end
    context '表示の確認' do
      it '編集前のタイトルと感想がフォームに表示(セット)されている' do
        expect(page).to have_field 'book[title]', with: book.title
        expect(page).to have_field 'book[body]', with: book.body
      end
      it 'Update Bookボタンが表示される' do
        expect(page).to have_button 'Update Book'
      end
      it 'Showリンクが表示される' do
        show_link = find_all('a')[0]
        expect(show_link.native.inner_text).to match(/show/i)
			end  
      it 'Backリンクが表示される' do
        back_link = find_all('a')[1]
        expect(back_link.native.inner_text).to match(/back/i)
			end  
    end
    context 'リンクの遷移先の確認' do
      it 'Showの遷移先は編集画面か' do
        show_link = find_all('a')[0]
        show_link.click
        expect(current_path).to eq('/books/' + book.id.to_s)
      end
      it 'Backの遷移先は一覧画面か' do
        back_link = find_all('a')[1]
        back_link.click
        expect(page).to have_current_path books_path
      end
    end
    context '更新処理に関するテスト' do
      it '更新に成功しサクセスメッセージが表示されるか' do
        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
        click_button 'Update Book'
        expect(page).to have_content 'successfully'
      end
      it '更新に失敗しエラーメッセージが表示されるか' do
        fill_in 'book[title]', with: ""
        fill_in 'book[body]', with: ""
        click_button 'Update Book'
        expect(page).to have_content 'error'
      end
      it '更新後のリダイレクト先は正しいか' do
        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
        click_button 'Update Book'
        expect(page).to have_current_path book_path(book)
      end
    end
  end
end



# require 'rails_helper'

# RSpec.feature "動作に関するテスト", type: :feature do
#   before do
#     2.times do
#       FactoryBot.create(:book)
#     end
#   end
#   scenario "トップ画面(root_path)に新規投稿ページへのリンクが表示されているか" do
#     visit root_path
#     expect(page).to have_link "", href: books_path
#   end
#   feature "bookの一覧ページの表示とリンクは正しいか" do
#     before do
#       visit books_path
#     end
#     scenario "bookの一覧表示(tableタグ)と投稿フォームが同一画面に表示されているか" do
#       has_field?('body')
#       has_table?('body')
#     end
#     scenario "bookのタイトルと感想を表示し、詳細・編集・削除のリンクが表示されているか" do
#       Book.all.each do |book|
#         expect(page).to have_content book.title
#         expect(page).to have_content book.body
#         expect(page).to have_link "", href: book_path(book)
#         expect(page).to have_link "", href: edit_book_path(book)
#         expect(page).to have_link "", href: book_path(book)
#       end
#     end
#   end
#   feature "bookの詳細ページへの表示内容とリンクは正しいか" do
#     given(:book) {Book.first}
#     before do
#       visit book_path(book)
#     end
#     scenario "bookの詳細内容と新規登録、編集ページへのリンクが表示されているか" do
#       expect(page).to have_content book.title
#       expect(page).to have_content book.body
#       expect(page).to have_link "", href: edit_book_path(book)
#       expect(page).to have_link "", href: books_path
#     end
#   end
#   feature "bookを投稿" do
#     before do
#       visit books_path
#       fill_in 'book[title]', with: 'title_a'
#       fill_in 'book[body]', with: 'body_b'
#     end
#     scenario "正しく保存できているか" do
#       expect{
#         find("input[name='commit']").click
#       }.to change(Book, :count).by(1)
#     end
#     scenario "リダイレクト先は正しいか" do
#       find("input[name='commit']").click
#       expect(page).to have_current_path book_path(Book.last)
#     end
#     scenario "サクセスメッセージは正しく表示されるか" do
#       find("input[name='commit']").click
#       expect(page).to have_content "successfully"
#     end
#   end
#   feature "bookの更新" do
#     before do
#       book = Book.first
#       visit edit_book_path(book)
#       fill_in 'book[title]', with: 'update_title_a'
#       fill_in 'book[body]', with: 'update_body_b'
#     end
#     scenario "bookが更新されているか" do
#       find("input[name='commit']").click
#       expect(page).to have_content "update_title_a"
#       expect(page).to have_content "update_body_b"
#     end
#     scenario "リダイレクト先は正しいか" do
#       find("input[name='commit']").click
#       expect(page).to have_current_path book_path(Book.first)
#     end
#     scenario "サクセスメッセージが表示されているか" do
#       find("input[name='commit']").click
#       expect(page).to have_content "successfully"
#     end
#   end
#   feature "bookの削除" do
#     before do
#       visit books_path
#     end
#     scenario "bookが削除されているか" do
#       expect {
#       all("a[data-method='delete']").select{|n| n[:href] == book_path(Book.first)}[0].click
#       }.to change(Book, :count).by(-1)
#     end
#     scenario "リダイレクト先が正しいか" do
#       all("a[data-method='delete']").select{|n| n[:href] == book_path(Book.first)}[0].click
#       expect(page).to have_current_path books_path
#     end
#   end
# end
