(package-initialize)
(require 'cl)
(require 'org)
(require 'org-roam)
(require 'org-roam-export)
(require 'org-roam-dailies)

(setq make-backup-files 'nil)
(setq org-roam-directory (file-truename "~/org-roam-garden/org-roam/"))
;; we apparently don't need to set a connector in Emacs 29 and above
(if (version< emacs-version "29")
    (setq org-roam-database-connector 'sqlite))
(setq org-roam-db-location (concat org-roam-directory ".org-roam.db"))

(setq org-hugo-base-dir "~/org-roam-garden/")
(setq org-hugo-section ".")
(setq org-hugo-front-matter-format "yaml")
(setq org-time-stamp-custom-formats '("%Y-%m-%d" . "%Y-%m-%d %H:%M"))

(defun make-inout-pair (f indir outdir)
  (let ((prefix-regex (format "^%s" indir))
        (md-file (concat (file-name-sans-extension f) ".md")))
    (cons f (replace-regexp-in-string prefix-regex outdir md-file))))

(defun newer (pair)
  (file-newer-than-file-p (car pair) (cdr pair)))

(defun roamexport ()
  (org-roam-update-org-id-locations)
  (org-roam-db-sync)
  (let* ((indir (expand-file-name "~/org-roam-garden/org-roam"))
         (outdir (expand-file-name "~/org-roam-garden/content"))
         (search-path (file-name-as-directory indir))
         (org-files (directory-files-recursively search-path "\.org$"))
         (org-export-pair
          (mapcar (lambda(f) (make-inout-pair f indir outdir)) org-files))
         (org-export-update (remove-if-not 'newer org-export-pair))
         (num-files (length org-export-update))
         (cnt 1))
     (if (= 0 num-files)
        (message (format "No new org files to export in %s" search-path))
      (progn
        (message (format "Exporting %d files recursively from %S .."
                         num-files search-path))
        (dolist (org-export-pair org-export-update)
          (let ((org-file (car org-export-pair))
                (md-file (cdr org-export-pair)))
            (with-current-buffer (find-file-noselect org-file)
              (message (format "[%d/%d] Exporting %s to %s" cnt num-files org-file md-file))
              (org-hugo-export-wim-to-md :all-subtrees)
              (kill-buffer))
            (setq cnt (1+ cnt))))
        (message "Done!")))))

(defun bookexport ()
  (with-current-buffer (find-file-noselect "~/org-roam-garden/books.org")
    (message (format "Exporting book file"))
    (org-toggle-time-stamp-overlays)
    (org-html-export-to-html 'nil 'nil 'nil 't)
    (kill-buffer)))

(defun my-org-export-filter-timestamp-function (content backend info)
  "removes relevant brackets from a timestamp" 
  (when (org-export-derived-backend-p backend 'html)
    (replace-regexp-in-string "&[lg]t;\\|[][]" "" content)))

(add-to-list 'org-export-filter-timestamp-functions
             'my-org-export-filter-timestamp-function)

(add-to-list 'org-export-filter-planning-functions
             'my-org-export-filter-timestamp-function)

(add-to-list 'org-export-filter-property-drawer-functions
             'my-org-export-filter-timestamp-function)

(defun my-org-export-filter-rating-function (content backend info)
  "makes rating into stars"
  (when (org-export-derived-backend-p backend 'html)
    (replace-regexp-in-string ":star:" "&#x2605;" content)))

(add-to-list 'org-export-filter-property-drawer-functions
             'my-org-export-filter-rating-function)

(roamexport)
(bookexport)
