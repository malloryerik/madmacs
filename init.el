(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; I think this stops CUA-mode from taking over C-v and M-v
(setq cua-enable-cua-keys nil)

;; MULTIPLE CURSORS  see -> https://github.com/magnars/multiple-cursors.el
(require 'multiple-cursors)
(global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; ORG-MODE
;; turn on syntax highlighting in org-mode code blocks
(setq org-src-fontify-natively t)
;; hot keys from anywhere in emacs
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c b") 'org-iswitchb)
(global-set-key (kbd "C-c c") 'org-capture)
(setq org-default-notes-file "~/dropbox/notes.org")

(setq org-capture-templates
 '(("t" "Todo" entry (file+headline "~/dropbox/notes.org" "Tasks")
        "* TODO %?\n  %i\n  %a")
   ("j" "Journal" entry (file+datetree "~/dropbox/journal.org")
   "* %?\n %U\n ")
   ("a" "Argives" entry (file+datetree "~/dropbox/argives.org")
    "* %?\nEntered on %U\n  %i\n  %a")))

(setq org-agenda-include-diary t)
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(defun kdm/html2org-clipboard ()
  "Convert clipboard contents from HTML to Org and then paste (yank)."
  (interactive)
  (kill-new (shell-command-to-string "osascript -e 'the clipboard as \"HTML\"' | perl -ne 'print chr foreach unpack(\"C*\",pack(\"H*\",substr($_,11,-3)))' | pandoc -f html -t json | pandoc -f json -t org --no-wrap"))
  (yank))

;;;;;;;;;;;;;;;;;;
;; magit
(global-set-key (kbd "C-x g") 'magit-status)

;;;;;;;;;;;;;;;;;;
;; JS -- See also setup-js.el
(require 'js2-mode)
(require 'rjsx-mode)
(require 'react-snippets)

(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(add-hook 'js2-mode-hook 'electric-pair-mode)
(add-hook 'js2-mode-hook 'rjsx-mode)
(require 'indium)
(add-hook 'js2-mode-hook #'indium-interaction-mode)

;; -----------TERN
(require 'company)
(require 'company-tern)
(add-to-list 'company-backends 'company-tern)
(add-hook 'js2-mode-hook (lambda ()
                           (tern-mode)
                           (company-mode)))
                           
;; ;; Disable completion keybindings, as we use xref-js2 instead
;; (define-key tern-mode-keymap (kbd "M-.") nil)
;; (define-key tern-mode-keymap (kbd "M-,") nil)

;; ---------------TIDE
;; tide -- like tern but easier?
;; https://github.com/ananthakumaran/tide  <-- nice stuff!

;; Tide with JavaScript (it's made for typescript)
;; Create jsconfig.json in the root folder of your project. jsconfig.json is tsconfig.json with allowJs attribute set to true.

;; {
;;   "compilerOptions": {
;;     "target": "es2017",
;;     "allowSyntheticDefaultImports": true,
;;     "noEmit": true,
;;     "checkJs": true,
;;     "jsx": "react",
;;     "lib": [ "dom", "es2017" ]
;;   }
;; }

;; --- Keyboard shortcuts 	Description

;; M-. 	Jump to the definition of the symbol at point. With a prefix arg, Jump to the type definition.
;; M-, 	Return to your pre-jump position.
;; M-x tide-restart-server Restart tsserver. This would come in handy after you edit tsconfig.json or checkout a different branch.
;; M-x tide-documentation-at-point Show documentation for the symbol at point.
;; M-x tide-references List all references to the symbol at point in a buffer. References can be navigated using n and p. Press enter to open the file.
;; M-x tide-project-errors List all errors in the project. Errors can be navigated using n and p. Press enter to open the file.
;; M-x tide-rename-symbol Rename all occurrences of the symbol at point.
;; M-x tide-format Format the current region or buffer.
;; M-x tide-fix Apply code fix for the error at point. When invoked with a prefix arg, apply code fix for all the errors in the file that are similar to the error at point.
;; M-x tide-refactor Refactor code at point or current region.
;; M-x tide-jsdoc-template Insert JSDoc comment template at point.
;; M-x tide-verify-setup Show the version of tsserver.

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)


(setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))

(add-hook 'rjsx-mode-hook #'setup-tide-mode)

;; configure javascript-tide checker to run after your default javascript checker
;; (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)

;; (require 'web-mode)
;; (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
;; (add-hook 'web-mode-hook
;;           (lambda ()
;;             (when (string-equal "jsx" (file-name-extension buffer-file-name))
;;               (setup-tide-mode))))
;; ;; configure jsx-tide checker to run after your default jsx checker
;; (flycheck-add-mode 'javascript-eslint 'web-mode)
;; (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)


;; EIN - Emacs IPython / Jupyter 

(require 'ein)
(require 'ein-loaddefs)
(require 'ein-notebook)
(require 'ein-subpackages)
(require 'fountain-mode)

;; adaptive wrap -- wrap to level of indent
(when (fboundp 'adaptive-wrap-prefix-mode)
  (defun my-activate-adaptive-wrap-prefix-mode ()
    "Toggle `visual-line-mode' and `adaptive-wrap-prefix-mode' simultaneously."
    (adaptive-wrap-prefix-mode (if visual-line-mode 1 -1)))
  (add-hook 'visual-line-mode-hook 'my-activate-adaptive-wrap-prefix-mode))

;; RAILWAYCAT EMACS MAC PORT STUFF 
 (setq mac-option-modifier 'meta)
 (setq mac-command-modifier 'super)
 (setq mac-pass-command-to-system nil)
;; ! RAILWAYCAT

;; Aquamacs -- make sure no toolbar!
(tool-bar-mode 0)

(setq column-number-mode t)
(setq line-number-mode t)

;; Neotree 
(setq neo-window-width 20)
(setq neo-window-fixed-size nil) ;; make neo-window draggable

;; (set-face-attribute 'default t :font "Courier New" :family "Courier New")
; (set-face-attribute 'default nil :height 100)
;; (tool-bar-mode 1)


(tool-bar-mode -1)

(global-visual-line-mode t)

(setq-default line-spacing 2)


(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(global-set-key (kbd "C-<S-left>")  'windmove-left)
(global-set-key (kbd "C-<S-right>") 'windmove-right)
(global-set-key (kbd "C-<S-up>")    'windmove-up)
(global-set-key (kbd "C-<S-down>")  'windmove-down)

;; Make windmove work in org-mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; (global-set-key [s-left] 'windmove-left)
;; (global-set-key [s-right] 'windmove-right)
;; (global-set-key [s-up] 'windmove-up)
;; (global-set-key [s-down] 'windmove-down)

; (make-frame '((undecorated . t))) ;; borderless, i.e. no title bar

; (set-face-background 'vertical-border "black")
; (set-face-foreground 'vertical-border (face-background 'vertical-border))

;;;;
;; Packages
;;;;



;; PYTHON
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)

;; Define package repositories
(require 'package)

;; (add-to-list 'package-archives
;;              '("tromey" . "http://tromey.com/elpa/") t)

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; (add-to-list 'package-archives
;;              '("melpa" . "http://melpa.milkbox.net/packages/") t)


;; (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                          ("marmalade" . "http://marmalade-repo.org/packages/")


;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
;; (package-initialize)

;; Download the ELPA archive description if needed.
;; This informs Emacs about the latest versions of all packages, and
;; makes them available for download.
(when (not package-archive-contents)
  (package-refresh-contents))

;; Define he following variables to remove the compile-log warnings
;; when defining ido-ubiquitous
(defvar ido-cur-item nil)
(defvar ido-default-item nil)
(defvar ido-cur-list nil)
(defvar predicate nil)
(defvar inherit-input-method nil)

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
  '(;; makes handling lisp expressions much, much easier
    ;; Cheatsheet: http://www.emacswiki.org/emacs/PareditCheatsheet
    paredit

    ;; key bindings and code colorization for Clojure
    ;; https://github.com/clojure-emacs/clojure-mode
    clojure-mode

    ;; extra syntax highlighting for clojure
    clojure-mode-extra-font-locking

    ;; integration with a Clojure REPL
    ;; https://github.com/clojure-emacs/cider
    cider

    ;; allow ido usage in as many contexts as possible. see
    ;; customizations/navigation.el line 23 for a description
    ;; of ido
    ido-ubiquitous

    ;; Enhances M-x to allow easier execution of commands. Provides
    ;; a filterable list of possible commands in the minibuffer
    ;; http://www.emacswiki.org/emacs/Smex
    smex

    ;; project navigation
    projectile

    ;; colorful parenthesis matching
    rainbow-delimiters

    ;; edit html tags like sexps
    tagedit

    ;; git integration
    magit))

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)



(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
    (add-hook 'clojure-mode-hook #'paredit-mode)
    (add-hook 'clojure-mode-hook           #'enable-paredit-mode)
    (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
    (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
    (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
    (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
 (add-hook 'clojure-mode-hook #'paredit-mode)

;; On OS X, an Emacs instance started from the graphical user
;; interface will have a different environment than a shell in a
;; terminal window, because OS X does not run a shell during the
;; login. Obviously this will lead to unexpected results when
;; calling external utilities like make from Emacs.
;; This library works around this problem by copying important
;; environment variables from the user's shell.
;; https://github.com/purcell/exec-path-from-shell
(if (eq system-type 'darwin)
    (add-to-list 'my-packages 'exec-path-from-shell))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))


;; Place downloaded elisp files in ~/.emacs.d/vendor. You'll then be able
;; to load them.
;;
;; For example, if you download yaml-mode.el to ~/.emacs.d/vendor,
;; then you can add the following code to this file:
;;
;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;; 
;; Adding this code will make Emacs enter yaml mode whenever you open
;; a .yml file
(add-to-list 'load-path "~/.emacs.d/vendor")

;; set up racket for geiser-mode lisp mode
(setq geiser-racket-binary "/Applications/Racket-v6.10.1/bin/racket")
(add-to-list 'package-archives
  ;; choose either the stable or the latest git version:
  ;; '("melpa-stable" . "http://stable.melpa.org/packages/")
             '("melpa-unstable" . "http://melpa.org/packages/"))

;; racket mode
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/")
             t)



;;;;
;; Customization
;;;;

;; Add a directory to our load path so that when you `load` things
;; below, Emacs knows where to look for the corresponding file.
(add-to-list 'load-path "~/.emacs.d/customizations")

;; Sets up exec-path-from-shell so that Emacs will use the correct
;; environment variables
(load "shell-integration.el")

;; These customizations make it easier for you to navigate files,
;; switch buffers, and choose options from the minibuffer.
(load "navigation.el")

;; These customizations change the way emacs looks and disable/enable
;; some user interface elements
(load "ui.el")

;; These customizations make editing a bit nicer.
(load "editing.el")

;; Hard-to-categorize customizations
(load "misc.el")

;; For editing lisps
(load "elisp-editing.el")

;; Langauage-specific
(load "setup-clojure.el")
(load "setup-js.el")


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   (vector "#ffffff" "#ff9da4" "#d1f1a9" "#ffeead" "#bbdaff" "#ebbbff" "#99ffff" "#002451"))
 '(ansi-term-color-vector
   [unspecified "#14191f" "#d15120" "#81af34" "#deae3e" "#7e9fc9" "#a878b5" "#7e9fc9" "#dcdddd"])
 '(background-color "#202020")
 '(background-mode dark)
 '(blink-cursor-mode nil)
 '(coffee-tab-width 2)
 '(column-number-mode t)
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-mode nil nil (cua-base))
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(cursor-color "#cccccc")
 '(cursor-type (quote box))
 '(custom-safe-themes
   (quote
    ("36e46b05e50f6df3d405551cfcdc9ac1b8b34a783138f2ea436030d637cef965" "987b709680284a5858d5fe7e4e428463a20dfabe0a6f2a6146b3b8c7c529f08b" "3d5ef3d7ed58c9ad321f05360ad8a6b24585b9c49abcee67bdcbb0fe583a6950" "9811b0b21cbb21b462b711f1c7b05638ab3795d5e62eda682c64f999ac2a093d" "c48551a5fb7b9fc019bf3f61ebf14cf7c9cdca79bcb2a4219195371c02268f11" "148b9274876a3f930a3f03e96b7298e6afcf9a9849009e21f8696982b002e565" "b3775ba758e7d31f3bb849e7c9e48ff60929a792961a2d536edec8f68c671ca5" "72a81c54c97b9e5efcc3ea214382615649ebb539cb4f2fe3a46cd12af72c7607" "96998f6f11ef9f551b427b8853d947a7857ea5a578c75aa9c4e7c73fe04d10b4" "ce22122f56e2ca653678a4aaea2d1ea3b1e92825b5ae3a69b5a2723da082b8a4" "9b59e147dbbde5e638ea1cde5ec0a358d5f269d27bd2b893a0947c4a867e14c1" "58c6711a3b568437bab07a30385d34aacf64156cc5137ea20e799984f4227265" "e9776d12e4ccb722a2a732c6e80423331bcb93f02e089ba2a4b02e85de1cf00e" "3cc2385c39257fed66238921602d8104d8fd6266ad88a006d0a4325336f5ee02" "e0d42a58c84161a0744ceab595370cbe290949968ab62273aed6212df0ea94b4" "3cd28471e80be3bd2657ca3f03fbb2884ab669662271794360866ab60b6cb6e6" "c620ce43a0b430dcc1b06850e0a84df4ae5141d698d71e17de85e7494377fd81" "2183cb6b0f7143137260949def874b5f63945d9fed1f713d09148aa485a31439" "ff7625ad8aa2615eae96d6b4469fcc7d3d20b2e1ebc63b761a349bebbb9d23cb" "23ec18fd244bcbee6f82eb3355dc7da084ad8f0c103d03fb58cc77d388d7df51" "20e23cba00cf376ea6f20049022241c02a315547fc86df007544852c94ab44cb" "e297f54d0dc0575a9271bb0b64dad2c05cff50b510a518f5144925f627bb5832" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "b25040da50ef56b81165676fdf1aecab6eb2c928fac8a1861c5e7295d2a8d4dd" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "787574e2eb71953390ed2fb65c3831849a195fd32dfdd94b8b623c04c7f753f0" "2e1e2657303116350fe764484e8300ca2e4cf45a73cdbd879bc0ca29cb337147" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "62408b3adcd05f887b6357e5bd9221652984a389e9b015f87bbc596aba62ba48" "1e67765ecb4e53df20a96fb708a8601f6d7c8f02edb09d16c838e465ebe7f51b" "2dc4191c0bb7406a2fe078e642e23a54bf169709eb3cc3f14ce07bbe430a9301" "eb34ed27768eeea1e423f8987b060e49829aac558fe0669b3de0227da67b661c" "5acb6002127f5d212e2d31ba2ab5503df9cd1baa1200fbb5f57cc49f6da3056d" "413e83eb87e162caa2fb6b2d0811cb8e9810ec1b5ddcf70ab67b23f127cc88c6" "51ba4e2db6df909499cd1d85b6be2e543a315b004c67d6f72e0b35b4eb1ef3de" "876f929fb7d2e244f149be1d342020004aa16793224794ebc26560751833b880" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "a632c5ce9bd5bcdbb7e22bf278d802711074413fd5f681f39f21d340064ff292" "01ce486c3a7c8b37cf13f8c95ca4bb3c11413228b35676025fdf239e77019ea1" "84e39ed4c552b75e1cb09458c140a9b025598002533456b4c27db31d27e1e0d7" "4980e5ddaae985e4bae004280bd343721271ebb28f22b3e3b2427443e748cd3f" "15348febfa2266c4def59a08ef2846f6032c0797f001d7b9148f30ace0d08bcf" "aae95fc700f9f7ff70efbc294fc7367376aa9456356ae36ec234751040ed9168" "47744f6c8133824bdd104acc4280dbed4b34b85faa05ac2600f716b0226fb3f6" "01233edda791c889d4e8e72fd71c915c8d9c38d544d2cc438a285c2d66d6daa3" "5dc0ae2d193460de979a463b907b4b2c6d2c9c4657b2e9e66b8898d2592e3de5" "b5f3e84ebbc8a4ac6c57ab7b4888f868b939db2cdabed5899069c88f3ed32f44" "540ad69df4e8cbd25b0130ad312efcfa443ee1d4c380d683939bedd3d915e525" "7a3568c84ae29edd9b0422a2bad5cff0326ed1ec5e9dbfcd5929df761eefde3c" "8b4c6eac11653c45cbae6c800a5ee3186d402f7368c0e8e2504b880803f2c378" "3acd6c080ef00f41997222d10253cb1eefc6f5229a63ccf0a7515fb98b09e88a" "ade241807d5b43f335f0a7394a1608911f272ea00c81bc0d8448801719d9da0a" "a56a6bf2ecb2ce4fa79ba636d0a5cf81ad9320a988ec4e55441a16d66b0c10e0" "30fe7e72186c728bd7c3e1b8d67bc10b846119c45a0f35c972ed427c45bacc19" "718fb4e505b6134cc0eafb7dad709be5ec1ba7a7e8102617d87d3109f56d9615" "195a14d655a1ccf8e4c7ce26972c3b07c3e6551b046744d873281e724f3f1f5a" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "246a51f19b632c27d7071877ea99805d4f8131b0ff7acb8a607d4fd1c101e163" "98cc377af705c0f2133bb6d340bf0becd08944a588804ee655809da5d8140de6" "6ee6f99dc6219b65f67e04149c79ea316ca4bcd769a9e904030d38908fd7ccf9" "59d86af1b7ac4ef89e40e5356c63a67627bc291218dd66cbe3632fc16a9f4555" "7f1263c969f04a8e58f9441f4ba4d7fb1302243355cb9faecb55aec878a06ee9" "d9bc74fa387ce18a353f2caebe29d79e0b3d73480a32e1e60ef6cfd30414c8e3" "5a8b00b6e82107d87cbfea6adade660126b20ad20ece9a3a44ef7f2fecf7d808" "97deb9a06117c25845cd343b6f0f9007d8662a09f10da8f9a93cafc1e4ffd9d8" "5975c13fedb2fc2b92526c1f011d288cd34a512ddf9deef7d89a009ffe830cc8" "e316a3e0172cc2b6223fa3f8a54defcb351b60fd675be1cd7b78bf15154414a6" "74927592579c4fcfb32a3c229ac97d69ec3ea03e5edfc7df39fe22720cb2beb4" "237e080fdea4eff2b88807306fd20d790e64c29bf97401f760fc09bd290fb719" "771ed57a21fe40073472f269d0fde3eb4e4eec1d6394f60468548ebd4b6903b3" "8ed752276957903a270c797c4ab52931199806ccd9f0c3bb77f6f4b9e71b9272" "889a93331bc657c0f05a04b8665b78b3c94a12ca76771342cee27d6605abcd0e" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "4739cbf1443109e081bb76ee79d587befe1f7fe02024d11baf01e11879299185" "cdd26fa6a8c6706c9009db659d2dffd7f4b0350f9cc94e5df657fa295fffec71" "e8825f26af32403c5ad8bc983f8610a4a4786eb55e3a363fa9acb48e0677fe7e" "810ab30a73c460f5c49ede85d1b9af3429ff2dff652534518fa1de7adc83d0f6" "d8f76414f8f2dcb045a37eb155bfaa2e1d17b6573ed43fb1d18b936febc7bbc2" "d51bb292e403a739c103071fd73e4277269e71653c5ed6f872acb01be70917b4" "10376427e2b8fa310a3dcdca5c028d321c7956ac8647e1ae846f28ad9f71eb0e" "1157a4055504672be1df1232bed784ba575c60ab44d8e6c7b3800ae76b42f8bd" "ecee7eb8284c658af20a640e0d16047a6e9e889e7e6b51b3041f1efc1579194d" "48d7eb8d0cf2066104ea5819757e199ce29870f9cb88e29b6237ed64c02e33a1" "cf08ae4c26cacce2eebff39d129ea0a21c9d7bf70ea9b945588c1c66392578d1" "5ee12d8250b0952deefc88814cf0672327d7ee70b16344372db9460e9a0e3ffc" "9e54a6ac0051987b4296e9276eecc5dfb67fdcd620191ee553f40a9b6d943e78" "52588047a0fe3727e3cd8a90e76d7f078c9bd62c0b246324e557dfa5112e0d0c" default)))
 '(default-input-method "french-alt-postfix")
 '(electric-pair-mode t)
 '(fci-rule-character-color "#192028")
 '(fci-rule-color "#00346e")
 '(foreground-color "#cccccc")
 '(fringe-mode 6 nil (fringe))
 '(global-hl-line-mode nil)
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   (quote
    (("#073642" . 0)
     ("#546E00" . 20)
     ("#00736F" . 30)
     ("#00629D" . 50)
     ("#7B6000" . 60)
     ("#8B2C02" . 70)
     ("#93115C" . 85)
     ("#073642" . 100))))
 '(hl-bg-colors
   (quote
    ("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
   (quote
    ("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(hl-paren-background-colors (quote ("#2492db" "#95a5a6" nil)))
 '(hl-paren-colors (quote ("#ecf0f1" "#ecf0f1" "#c0392b")))
 '(hl-sexp-background-color "#1c1f26")
 '(js2-missing-semi-one-line-override t)
 '(js2-strict-missing-semi-warning nil)
 '(linum-format " %1d ")
 '(magit-commit-arguments nil)
 '(magit-diff-use-overlays nil)
 '(main-line-color1 "#191919")
 '(main-line-color2 "#111111")
 '(nrepl-message-colors
   (quote
    ("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4")))
 '(org-agenda-files (quote ("~/Google Drive/orgmode/argives.org")))
 '(org-block-background ((t (:height 0.8 :family "Source Code Pro"))))
 '(org-code
   ((t
     (:background "#FDFFF7" :foreground "#006400" :family "Monaco"))))
 '(org-table ((t (:foreground "Blue1" :family "Courier New"))))
 '(package-selected-packages
   (quote
    (adaptive-wrap org-easy-img-insert magit sublime-themes faff-theme react-snippets telephone-line evil-anzu powerline-evil atom-one-dark-theme dracula-theme tide company-tern ## discover-js2-refactor js2-mode itail indium osx-dictionary rjsx-mode color-theme-sanityinc-tomorrow fountain-mode ac-alchemist alchemist ein ein-mumamo ac-python ac-anaconda eldoc-overlay-mode css-eldoc cljdoc org-bullets lua-mode multiple-cursors web-mode clojure-project-mode typed-clojure-mode cider-decompile move-line spacegray-theme solarized-theme occidental-theme monokai-theme naquadah-theme farmhouse-theme rainbow-mode ac-cider neotree tagedit smex rainbow-delimiters projectile paredit ido-ubiquitous exec-path-from-shell)))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(powerline-color1 "#191919")
 '(powerline-color2 "#111111")
 '(show-paren-mode t)
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(sml/active-background-color "#34495e")
 '(sml/active-foreground-color "#ecf0f1")
 '(sml/inactive-background-color "#dfe4ea")
 '(sml/inactive-foreground-color "#34495e")
 '(telephone-line-mode nil)
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(text-scale-mode-step 1.1)
 '(tool-bar-mode nil)
 '(variable-pitch ((t (:family "Avenir"))))
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#bf616a")
     (40 . "#DCA432")
     (60 . "#ebcb8b")
     (80 . "#B4EB89")
     (100 . "#89EBCA")
     (120 . "#89AAEB")
     (140 . "#C189EB")
     (160 . "#bf616a")
     (180 . "#DCA432")
     (200 . "#ebcb8b")
     (220 . "#B4EB89")
     (240 . "#89EBCA")
     (260 . "#89AAEB")
     (280 . "#C189EB")
     (300 . "#bf616a")
     (320 . "#DCA432")
     (340 . "#ebcb8b")
     (360 . "#B4EB89"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (quote
    (unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83")))
 '(when
      (or
       (not
        (boundp
         (quote ansi-term-color-vector)))
       (not
        (facep
         (aref ansi-term-color-vector 0)))))
 '(xterm-color-names
   ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#eee8d5"])
 '(xterm-color-names-bright
   ["#002b36" "#cb4b16" "#586e75" "#657b83" "#839496" "#6c71c4" "#93a1a1" "#fdf6e3"]))



;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(org-block-background ((t (:height 0.8 :family "Source Code Pro"))))
;;  '(org-code ((t (:background "#FDFFF7" :foreground "#006400" :family "Monaco"))))
;;  '(org-table ((t (:foreground "Blue1" :family "Courier New"))))
;;  '(variable-pitch ((t (:family "Avenir")))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
