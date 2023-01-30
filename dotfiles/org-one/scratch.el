;; [[file:../.doom.d/dot.org::*Scratch.el][Scratch.el:1]]
;;; scratch.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 nhannht
;;
;; Author: nhannht <nhanclassroom@gmail.com>
;; Maintainer: nhannht <nhanclassroom@gmail.com>
;; Created: July 10, 2022
;; Modified: July 10, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/vermin/scratch
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:
(require 'parse-csv)
(require 'jupyter)
(require 's)
(require 'mode-local)
(defconst ext-list (mapcar #'s-trim
                           (parse-csv->list (with-temp-buffer
                                              (insert-file-contents "~/org-one/ext-code.csv")
                                              (buffer-string)))))

(defun vermin/find-scratch-file ()
  "Ask for extension and create a scratch file."
  (interactive)
  (let* ((ext (completing-read "Choose extension or type your own "
                               ext-list nil nil))
         (file-name (file-name-concat (getenv "HOME")
                                      "org-one"
                                      (concat "scratch." ext))))
    (find-file-other-window file-name)
    (goto-char (point-max))))


;;; Scratch
(defun example-action-function (target)
  (message "The target was `%s'." target))

(map! :leader :prefix
      "w"
      ((:in "<left>" #'evil-window-left)
       (:in "<right>" #'evil-window-right)
       (:in "<up>" #'evil-window-up)
       (:in "<down>" #'evil-window-down)))



(jupyter-sha256 (current-time-string))



(defun vermin/jupyter-src-block-insert ()
  (interactive)
  (let* ((kernels (mapcar #'car
                          (jupyter-available-kernelspecs)))
         (kernel (completing-read "Choose your kernel" kernels
                                  nil nil)))
    (insert (format "#+BEGIN_SRC jupyter :kernel %s :session %s\n\n#+END_SRC"
                    kernel kernel))
    (forward-line -1)))

(defun vermin/find-scrum-file ()
  (interactive)
  (find-file "~/org/org-one/main-scrum.org"))

(defun vermin/org-scrum-insert-task ())

(map! :map prog-mode-map
      (:in "C-<return>" #'outshine-insert-heading))

(defun vermin/file-header-insert ()
  (interactive)
  (call-interactively #'add-file-local-variable-prop-line))

(defun vermin/org-scrum-add-task (task)
  (interactive "sName of your task: ")
  (insert (format "*** TODO %s" task))
  (org-set-property "OWNER" "nhannht")
  (org-set-property "ESTIMATED" "0")
  (org-set-property "ACTUAL" "0")
  (org-set-property "TASKID" "??"))

(map! :map prog-mode-map
      (:in "C-c C-n" #'jupyter-org-execute-and-next-block)
      (:in "C-c C-p" #'jupyter-org-previous-busy-src-block))

(defun vermin/parse-org-template-for-cli ()
  (let* ((li  (cl-map 'list (lambda (x)(list (nth 0 x) (nth 1 x))) org-capture-templates))
         (li-fil  (seq-filter (lambda (y)  (> (length (nth 0 y))
                                              1))
                              li)))
    (string-join  (cl-loop for i in li-fil
                           collect  (format "%s : %s" (nth 0 i) (nth 1 i)))
                  "\n")))

(message (vermin/parse-org-template-for-cli))

(map! :map org-mode-map ((:in "C-n" #'next-line)
                         (:in "C-p" #'previous-line)))

(use-package! org
  :defer t
  :config
  (setq! org-structure-template-alist  '(("S" . "src shell  :results html :eval t")
                                         ("p" . "src python :session python :async yes  ")
                                         ("a" . "export ascii")
                                         ("r" . "src jupyter :kernel ssh :session ssh :async yes")
                                         ("c" . "center")
                                         ("C" . "comment")
                                         ("e" . "example")
                                         ("E" . "export")
                                         ("h" . "export html")
                                         ("l" . "export latex")
                                         ("q" . "quote")
                                         ("s" . "src")
                                         ("v" . "verse"))))
;; (map! :map org-mode-map :leader :prefix "m" (:in "v" #'org-babel-demarcate-block)  )
(map!  :map pdf-view-mode-map "TAB" #'org-noter-insert-note-toggle-no-questions )

(map!    (:prefix "SPC" :map pdf-view-mode-map  :in "v" #'org-noter-create-skeleton ) )

(setq vermin/pwa '("https://excalidraw.com/"
                   "https://dbdiagram.io/d"))

(defun vermin/find-web-app ()
  (interactive)
  (let ((app (completing-read "Choose your PWA " vermin/pwa nil nil)))
    (if  (executable-find "chromium")
        (async-shell-command (format  "/usr/bin/env chromium --app=%s" app)))))

(add-hook!
 '(calibredb-show-mode calibre-search-mode calibredb-search-mode-hook) #'evil-emacs-state)

(map!  :map prog-mode-map
       :leader
       :prefix "m" ( (:in "r d"  #'srefactor-lisp-format-defun)
                     (:in "r s" #'srefactor-lisp-format-sexp)
                     ))

(map! :map org-mode-map "C-'" #'+fold/toggle)

;;;; Remap evil-open-below with my custom key

(defun vermin/get-src-blk-lang ()
  "get language of src block"
  (interactive)
  (nth 0 (org-babel-get-src-block-info)))

(defun vermin/get-buffer-file-name-ext ()
  "return empty string if buffer is scratch or non-file buffer"
  (let ((name (buffer-file-name)))
    (if name
        (file-name-extension name)
      "")
    ))

(defun vermin/evil-open-below ()
  "Fix the bug when enter new line in org babel bash block"
  (interactive)
  (let ((ext (vermin/get-buffer-file-name-ext)))
    (cond
     ((not (string-equal ext "org"))
      (evil-open-below 1))
     ((and (eq evil-state 'normal)
           (org-in-src-block-p)
           (member (vermin/get-src-blk-lang) '("bash" "shell")))
      (progn
        (evil-insert-newline-below)
        (evil-insert-state)))
     (t (evil-open-below 1)))))

(defun vermin/evil-open-above ()
  "Fix the bug when enter new above line in org babel bash block"
  (interactive)
  (let ((ext (vermin/get-buffer-file-name-ext)))
    (cond
     ((not (string-equal ext "org"))
      (evil-open-above 1))
     ((and (eq evil-state 'normal)
           (org-in-src-block-p)
           (member (vermin/get-src-blk-lang) '("bash" "shell")))
      (progn
        (evil-insert-newline-above )
        (evil-insert-state)))
     (t (evil-open-above 1)))))



;; Wtf, it pass sympol as a argument instead of function
(evil-define-key 'normal 'evil-org-mode-map (kbd "O") #'vermin/evil-open-above)

(evil-define-key 'normal 'evil-org-mode  (kbd "o") 'vermin/evil-open-below)
(defun vermin/org-return ()
  "replace org-return/evil-org-return which bug in org babel bash block"
  (interactive)
  (if (and  (member evil-state '(insert))
            (org-in-src-block-p )
            (member  (vermin/get-src-blk-lang) '("bash" "shell") ))
      (progn
        (org-return-and-maybe-indent )
        )
    (+org/return))
  )

(evil-define-key 'insert 'evil-org-mode (kbd "<return>") 'vermin/org-return)

(use-package! org
  :defer t
  :init
  (setq org-startup-with-inline-images t)
  (setq org-startup-with-latex-preview t)
  (setq +org-startup-with-animated-gifs t))
(use-package! python
  :defer t
  :init (defun vermin/python-describe-at-point (symbol process)
          (interactive (list (python-info-current-symbol)
                             (python-shell-get-process)))
          (comint-send-string process
                              (concat "?? " symbol "\n")))
  :config
  (setq python-section-delimiter "#%%")
  (setq python-section-highlight t))

(use-package! py-prof
  :defer t)
(use-package! python-x
  :defer t
  :config
  (python-x-setup))

(use-package! python
  :defer t
  :config
  (defun vermin/python-describe-at-point (symbol process)
    (interactive (list (python-info-current-symbol)
                       (python-shell-get-process)))
    (comint-send-string process (concat "?? " symbol "\n" )))

  (defun vermin/python-describe-at-point-mini (symbol process)
    (interactive (list (python-info-current-symbol)
                       (python-shell-get-process)))
    (comint-send-string process (concat "? " symbol "\n" )))
  (map! :map python-mode-map  ((:i "C-c g" #'+company/complete )
                               (:i "C-c C-g" #'+company/complete)
                               (:in "C-c M-d" #'vermin/python-describe-at-point-mini))))

(use-package! edraw
  :defer t
  :config
  (defun turn-on-edraw-org-link-image-mode ()
    "Turn on this edraw-org display inline image "
    (when (string-equal major-mode "org-mode")
      (edraw-org-link-image-mode 1))))

(define-globalized-minor-mode global-edraw-org-link-image-mode edraw-org-link-image-mode turn-on-edraw-org-link-image-mode
  :init-value t
  (if global-edraw-org-link-image-mode
      (add-hook 'org-mode-hook #'edraw-org-link-image-mode)
    (remove-hook 'org-mode-hook #'edraw-org-link-image-mode )))

(use-package! edraw
  :after org
  )
(use-package! edraw-org
  :after edraw
  :commands #'edraw-org-edit-link
  :config
  (edraw-org-setup-default)
  (setq global-edraw-org-link-image-mode t))

(use-package! ibuffer
  :defer t
  :init
  (add-hook 'ibuffer-hook #'evil-emacs-state))

(setq enable-local-variables :safe)



(setq safe-local-variable-values '(( find-file-hook . org-babel-execute-buffer)
                                   (find-file-hook . (lambda ()(interactive)
                                                       (message "hello ")))))
;; (use-package! poetry)
;; (defun vermin/dashboard-startup-hook ()
;;     (progn
;;         (poetry-venv-workon)
;;         (org-babel-execute-buffer)))

;; (setq debug-on-error 1)


(defun vermin/dashboard-edit ()
  (interactive)
  (let ((dashboard  "~/org-one/dashboard.org"))
    (if (file-exists-p
         dashboard)
        (find-file dashboard)
      (error (string  "No " dashboard  "file found"))))

  (defun vermin/vterm-org-babel-src-blk-dir (&optional blk-name)
    (interactive)
    (let ((dir (cdr (assoc :dir (nth 2
                                     (org-babel-get-src-block-info))))))
      (if dir
          (with-temp-buffer
            (setq default-directory  dir)
            (vterm))
        (progn
          (message "This src block dont have :dir header, so open current directory")
          (vterm)))
      )
    )
  (add-hook 'org-babel-after-execute-hook #'save-buffer)
  (setq! org-element-use-cache nil
         org-export-babel-evaluate nil))
(defun vermin/howdoi-query ()
  "Call howdoi shell command and return result other window, work on both symbol at point or region"
  (interactive)
  (let* (( in (read-string "Ask your answer: "))
         (query (format "%s" in  )))
    (with-current-buffer (get-buffer-create "*howdoi output*")
      (erase-buffer)

      (insert (format "%s " query))
      (insert (shell-command-to-string (format "howdoi %s -n 5" query) ))
      (pop-to-buffer (current-buffer))
      (helpful-mode)
      (setq buffer-read-only nil)
      (beginning-of-buffer ))))

(defun vermin/howdoi ()
  "Call howdoi shell command and return result other window, work on both symbol at point or region"
  (interactive)
  (let* (( in (if mark-active
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (symbol-name (symbol-at-point))))
         (query (format  "howdoi -n 5 How to use %s in %s"
                         in (vermin/get-major-language-current-buffer) ))
         )
    (with-current-buffer (get-buffer-create "*howdoi output*")
      (erase-buffer)

      (insert (format "%s \n " query))
      (insert (shell-command-to-string query ))
      (pop-to-buffer (current-buffer))
      (helpful-mode)
      (setq buffer-read-only nil))))

(use-package! howdoyou
  :commands howdoyou-query
  :config
  (setq howdoyou-switch-to-answer-buffer t)
  (setq howdoyou-max-history 100)
  )
(use-package! wolfram
  :defer t
  :config
  (setq wolfram-alpha-app-id  "K8AKR2-62T7EH48V5"))
(use-package! point-history
  :defer t
  :config
  (point-history-mode 1)
  (setq point-history-save-timer 5)
  (map! :mode point-history-show-mode
        ((:inev "RET" #'point-history-preview-at-point)
         (:inev "q" #'point-history-quit))) )

(use-package! hnreader
  :defer t)
(use-package! helm-net
  :commands helm-google-suggest)

;; (add-to-list '+emacs-lisp-disable-flycheck-in-dirs "~/org-one")
(map! :leader  :prefix-map ( "r" . "vermin help map")
      (:ine "e" #'vermin/howdoi-query)
      (:ine "r" #'helm-google-suggest)
      (:ine  "a" #'+lookup/in-all-docsets)
      (:ine "s" #'+lookup/in-docsets)
      (:ine "g" #'devdocs-lookup)
      (:ine "l" #'devdocs-install)
      (:ine "k" #'dash-docs-install-docset)
      (:ine "K" #'dash-docs-install-user-docset)
      (:ine "w" #'wolfram-alpha)
      (:ine "c" #'cheat-sh-maybe-region)
      )
(map! :leader ((:ine "s h" #'ivy-point-history)))
(setq org-directory "~/org-one")
(defun vermin/todo-find-central-file ()
  (interactive)
  (find-file-other-frame (expand-file-name +org-capture-todo-file org-directory)))

(defun vermin/todo-find-local-file
    (interactive)
  (find-file-other-window (+org--capture-local-root +org-capture-todo-file) ))
(defcustom vermin/scratch-el-file "~/org-one/scratch.el"
  "The file to store the scratch elisp file  ."
  :type 'file
  :group 'vermin)
(defun vermin/scratch-el-find-file ()
  (interactive)
  (find-file-other-frame vermin/scratch-el-file))

(map! :leader  "SPC" #'counsel-ibuffer)
(map! :leader (("s w" #'counsel-wmctrl)
               ("s u" #'counsel-outline)
               ("s I" #'counsel-etags-list-tag-in-current-file)
               ("s q" #'counsel-locate)
               ))

(map! :leader (("f t" #'vermin/todo-find-file)
               ("f x" #'vermin/scratch-el-find-file)
               ("f a" #'vermin/dashboard-edit)))
(use-package company
  :defer t
  :config
  (setq company-idle-delay 1))

;; (use-package! poetry
;;   :config
;;   (poetry-tracking-mode -1)
;;   (setq poetry-tracking-strategy 'projectile))
(use-package! copilot
  :defer t
  :config
  (setq copilot-idle-delay 1))
;; (use-package! poetry
;;   :config
;;   (setq! poetry-tracking-mode nil
;;          poetry-tracking-strategy 'switch-buffer))


;; (setq! eval-expression-debug-on-error nil
;;        debug-on-error nil
;;        edebug-on-error nil)
(setq enable-local-variables :all)
;; (use-package! virtualenvwrapper
;;   :config
;;   (venv-initialize-interactive-shells)
;;   (venv-initialize-eshell))


(defvar vermin/org-capture-readme-file "README.org"
  "Default target for README file")
(defun vermin/org-capture-readme-file ()
  (expand-file-name vermin/org-capture-readme-file org-directory))

(defun vermin/org-capture-project-readme-file ()

  "Find the nearest README.org file in parent directory, otherwise, opens a blanks one at the project root. Throws an errors if not in a project"
  (+org--capture-local-root vermin/org-capture-readme-file))

(defun vermin/find-org-readme-local-project ()
  (interactive)
  (find-file (vermin/org-capture-project-readme-file)))

(use-package! semantic
  :defer t)

(defvar-mode-local emacs-lisp-mode imenu-create-index-function 'imenu-default-create-index-function)

(defun vermin-setup-imenu-elisp-mode ()
  (setq imenu-create-index-function #'imenu-default-create-index-function))
(add-hook 'emacs-lisp-mode-hook #'vermin-setup-imenu-elisp-mode)

(use-package! helm
  :defer t )

(use-package! helm-semantic
  :commands helm-semantic-or-imenu)

(use-package! helm-occur
  :commands (list helm-occur))

(use-package! inspector
  :defer t)


(defcustom vermin/evil-emacs-default-state-mode-alist nil
  "List of all mode that use emacs state as default"
  :type 'list )
(mapcar (lambda (mode)
          (evil-set-initial-state mode 'emacs)) vermin/evil-emacs-default-state-mode-alist)

(add-to-list 'vermin/evil-emacs-default-state-mode-alist 'inspector-mode)
(use-package! org
  :defer t
  :config
  (setq org-export-use-babel nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((http . t)
     (jupyter . t)
     )))

(defun vermin/load-jupyter ()
  (interactive)
  (use-package! jupyter)
  (use-package! jupyter-python
    :after jupyter)
  (use-package! ob-jupyter
    :after  jupyter))

(use-package! jupyter)
(use-package! ob-jupyter)

                                        ; (setq native-comp-always-compile t)
                                        ; (setq native-comp-speed 3)
;; (setq native-comp-deferred-compilation t)

                                        ; (defun vermin/dired-native-comp-mark-file ()
                                        ;   (interactive)
                                        ;   (mapc (lambda (mark-file)
                                        ;           (native-compile-async mark-file t t))
                                        ;         (dired-get-marked-files)))
;; (use-package! mixed-pitch
;;   :after org
;;   :config
;;   (add-hook 'org-mode-hook #'mixed-pitch-mode) )
(map! :map vterm-mode-map :in "C-b" #'vterm--self-insert)
(map! :map vterm-mode-map :in "w" #'vterm--self-insert)
(use-package! code-stats
  :after prog-mode
  :config
  (setq code-stats-token "SFMyNTY.Ym1oaGJtNW9kQT09IyNNVGM0T0RZPQ.JkyJb-d2_Y-LfmzWyGULtQFy6VAgGl4KKb9U5XaVJ98")
  (add-hook 'prog-mode-hook #'code-stats-mode)
  (run-with-idle-timer 30 t #'code-stats-sync)
  (add-hook 'kill-emacs-hook (lambda () (code-stats-sync :wait))))

(use-package! valign
  :disabled t
  :after org
  :config
  (setq valign-fancy-bar nil)
  (setq valign-max-table-size 100000))
(use-package! pollen-mode
  :init
  (add-to-list 'auto-minor-mode-alist '("\\.pp\\'" . pollen-minor-mode))
  :after racket-mode)

(with-eval-after-load "helm-net"
  (push (cons "How Do You"  (lambda (candidate) (howdoyou-query candidate)))
        helm-google-suggest-actions))
;; (use-package! grip-mode
;;   :commands ( grip-mode grip-browse-preview)
;;   :init
;;   (add-hook 'markdown-mode-hook #'grip-mode))

(use-package! pollen-mode
  :mode (("\\.pp\\'" . racket-mode)
         ("\\.pm\\'" . racket-mode)
         ("\\.html.p\\'" . web-mode))
  :hook (web-mode . emmet-mode)
  :config
  (add-to-list 'auto-minor-mode-alist '("\\.pp\\'" . pollen-minor-mode)
               )
  (add-to-list 'auto-minor-mode-alist '("\\.pm\\'" . pollen-minor-mode)
               )
  (add-to-list 'auto-minor-mode-alist '("\\.p\\'" . pollen-minor-mode)
               )
  )
(use-package! yaml-mode
  :mode (( "\\.yml\\'" . yaml-mode)
         ("\\.yaml\\'" . yaml-mode)))
(use-package! xonsh-mode :mode (( "\\.xsh\\'" . xonsh-mode)))
(use-package! counsel)
;;; scratch.el ends here
;; Scratch.el:1 ends here
