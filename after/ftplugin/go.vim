nnoremap <silent> <leader>r :AsyncRun -mode=term go run '$(VIM_FILEPATH)'<CR>
nnoremap <silent> <leader>R :AsyncRun -mode=term go build -o /tmp/a && /tmp/a<CR>