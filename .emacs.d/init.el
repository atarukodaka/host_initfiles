;; ================================================================
;; basic settings


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/elisp/")
;(add-to-list 'load-path "~/.emacs.d/elisp/org-mode")
(setq ring-bell-function 'ignore)    ;; beep off
(setq inhibit-startup-message t)

;; ================================================================
;; key assign

(global-set-key "\C-h" 'delete-backward-char)
(global-set-key (kbd "C-c e") 'eval-current-buffer)
(global-set-key (kbd "C-c l") 'goto-line)    ;; goto line
(global-set-key (kbd "C-x C-b") 'ibuffer)  ; ibuffer
;(global-set-key (kbd "C-m") 'newline-and-indent)

;;================================================================
;; language-mode

;; haml-mode
(autoload 'haml-mode "haml-mode" "Mode for editing haml files" t)
(setq auto-mode-alist  (append '(("\\.haml$" . haml-mode)) auto-mode-alist))

;; slim-mode
(autoload 'slim-mode "slim-mode" "Mode for editing slim source files" t)
(add-to-list 'auto-mode-alist '("\\.slim?\\'" . slim-mode))

;; .erb
(setq auto-mode-alist  (append '(("\\.erb$" . html-mode)) auto-mode-alist))
(setq auto-mode-alist  (append '(("\\.scss$" . css-mode)) auto-mode-alist))

;; ruby-mode
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)
(setq auto-mode-alist (append '(("\\.rb$" . ruby-mode)
				("\\.ruby$" . ruby-mode)
				("\\.ru$" . ruby-mode)
				("\\.rake$" . ruby-mode)
				("\\.cgi$" . ruby-mode)
				("Gemfile" . ruby-mode)
				(".gemspec" . ruby-mode)
				("Rakefile" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
(add-hook 'ruby-mode-hook
	  '(lambda ()
	     (electric-indent-mode 1)))
	     ;;	     (define-key ruby-mode-map "\C-m" 'newline-and-indent)))

;; yaml-mode

(autoload 'yaml-mode "yaml-mode" "" t)
(setq auto-mode-alist  (append '(("\\.yml$" . yaml-mode)) auto-mode-alist))
(add-hook 'yaml-mode-hook
	  '(lambda ()
	     (define-key yaml-mode-map "\C-j" 'newline-and-indent)))

;; markdown-mode
(autoload 'markdown-mode "markdown-mode" "" t)
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\.erb$" . markdown-mode))

;; robocup
;(require 'rubocop)
;(add-hook 'ruby-mode-hook 'rubocop-mode)


;; ================================================================
;; functions

;; ignore extension on file-open
(defadvice completion-file-name-table (after ignoring-backups-f-n-completion activate)
  "filter out results when the have completion-ignored-extensions"
  (let ((res ad-return-value))
    (if (and (listp res)
          (stringp (car res))
          (cdr res)) ; length > 1, don't ignore sole match
        (setq ad-return-value
          (completion-pcm--filename-try-filter res)))))

;; rename file and buffer
(global-set-key (kbd "C-x w") 'rename-file-and-buffer)
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))


;; delete file and buffer
(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
          (vc-delete-file filename)
        (progn
          (delete-file filename)
          (message "Deleted file %s" filename)
          (kill-buffer))))))


;; memo
;;(setq source-directory "~/vagrant/centos65/source/")
(setq source-directory "~/src/")
;(setq memo-filename (concat source-directory "site/source/memo.html.md"))
;(setq memo-filename (concat source-directory "extensions/middleman-akcms/CHANGELOG.md"))
(setq memo-filename (concat source-directory "fisk8/fisk8_result_viewer/README.md"))
(global-set-key (kbd "C-c m") (lambda () (interactive)(find-file memo-filename)))
(add-hook 'after-init-hook (lambda () (interactive)(find-file memo-filename)))

;; ================================================================
;; insert

;; insert date
(global-set-key (kbd "C-c d") 'insert-date)
(defun insert-date ()
  "insert date"
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

;; auto-insert
(define-skeleton frontmatter-skeleton
  "Default Frontmatter"
  ""
  "---\n"
  "title: \n"
  "date: " (format-time-string "%Y-%m-%d") "\n"
  "\n"
  "---"
  "\n\n"
  )

(require 'autoinsert)
(add-hook 'find-file-hooks 'auto-insert)
(setq auto-insert-query nil)
(setq auto-insert-alist 
      '(
	("\\.html\\.md$" . frontmatter-skeleton)
	("\\.html\\.md\\.erb$" . frontmatter-skeleton)
	))


;; snippet
(add-to-list 'load-path "~/.emacs.d/elisp/yasnippet")
(setq yas-snippet-dirs
      '("~/.emacs.d/snippets"
        "~/.emacs.d/yasnippet-snippets" ))


;; middleman-blog: article-front matter
(defun insert-article-frontmatter ()
  (interactive)
;  (insert (concat "---\ntitle: \ndate: " (format-time-string "%Y-%m-%d") "\ncategory: \n\n---\n")))
  (insert (concat "---\ntitle: \ndate: " (format-time-string "%Y-%m-%d") "\n\n---\n")))
(define-key global-map "\C-ca" 'insert-article-frontmatter)


;; org-jekyll
;(require 'ox-jekyll)

;================================================================
;; default directory

;;(cd "~/")
(setq default-directory "~/")
;;(setq command-line-default-directory "~/vagrant/centos65/source/")
(setq command-line-default-directory source-directory)

;; ================================================================
;; initial frame
(setq default-frame-alist
      (append (list '(foreground-color . "black")
		    '(background-color . "LemonChiffon")
		    '(background-color . "gray")
		    '(border-color . "black")
		    '(mouse-color . "white")
		    '(cursor-color . "black")
;;		    '(ime-font . (w32-logfont "ＭＳ ゴシック"
;;					      0 16 400 0 nil nil nil
;;					      128 1 3 49)) ; TrueType のみ
;;		    '(font . "bdf-fontset")    ; BDF
;;		    '(font . "private-fontset"); TrueType
		    '(width . 90)
		    '(height . 47)
		    '(top . 20)
		    '(left . 500))
	      default-frame-alist))

;; ================================================================
;;; japanese language
(set-language-environment "Japanese")
(set-default-coding-systems 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)

'(w32-ime-initialize)
(global-set-key [M-kanji] 'ignore) 
(global-set-key [kanji] 'ignore)  ; See more at: http://yohshiy.blog.fc2.com/blog-entry-169.html#sthash.P4hJnxxH.dpuf


;;;
;;; end of file
;;;
