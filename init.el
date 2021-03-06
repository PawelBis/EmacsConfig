;; Hide startup message
(setq inhibit-startup-message t)
(desktop-save-mode 1)

;; Hide clutter
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Disable annyoing warning sound
(setq visible-bell t)

;; Escape is now exiting from key combinations (like C-g)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-dracula t)
  (doom-themes-org-config))

(set-frame-font "Consolas 12" nil t)

(column-number-mode)
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . uvy-reverse-i-search-kill))
  :init
  (ivy-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package hydra)
(defhydra hydra-text-scale (:timeout 3)
  "scale text"
  ("j" text-scale-increase "increase")
  ("k" text-scale-decrease "decrease")
  ("q" nil "quit" :exit t))

(use-package general
:config
  (general-create-definer rune/leader-keys
:keymaps '(normal insert visual emacs)
:prefix "SPC"
:global-prefix "C-SPC"))

(rune/leader-keys
  "tt" '(counsel-load-theme :which-key "choose theme"))


(defun rune/evil-hook ()
  (dolist (mode '(custom-mode
		    eshell-mode
		    git-rebase-mode
		    erc-mode
		    circe-server-mode
		    circe-chat-mode
		    curce-query-mode
		    sauron-mode
		    term-mode))
	  (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (evil-mode 1)
  :hook (evil-mode . rune/evil-hook)
  :config
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (define-key evil-insert-state-map (kbd "C-l") 'evil-delete-char)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/projects/")
     (setq projectile-project-search-path '("~/projects/")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :init (counsel-projectile-mode))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-funciton #'magit-display-buffer-same-window-except-diff-v1))

(defun dw/org-mode-setup ()
  (dolist (face '((org-level-1 . 2.0)
	   ( org-level-2 . 1.5)
	   ( org-level-3 . 1.25)
	   ( org-level-4 . 1.1)
	   ( org-level-5 . 1.0)
	   ( org-level-6 . 1.0)
	   ( org-level-7 . 1.0)
	   ( org-level-8 . 1.0)
	   ( org-level-9 . 1.0)))
	  (set-face-attribute (car face) nil :font "Consolas" :weight 'regular :height (cdr face)))
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ???"
  org-hide-emphasis-markers t))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("???" "???" "???" "???" "???" "???" "???")))

(defun efs/org-babel-tangle-config()
  (when (string-match (buffer-file-name)
	       "init.org"))
  (let ((org-confirm-babel-evaluate-nil))
    (org-babel-tangle)))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))
