(package-initialize)
(require 'cl)
(require 'org)
(require 'org-roam)
(require 'org-roam-export)
(require 'org-roam-dailies)
(require 'ox-publish)

(setq make-backup-files 'nil)
(setq org-roam-directory (file-truename "~/org-roam-garden/org-roam"))
;; we apparently don't need to set a connector in Emacs 29 and above
(if (version< emacs-version "29")
    (setq org-roam-database-connector 'sqlite))
(setq org-roam-db-location (concat org-roam-directory "/.org-roam.db"))

(setq org-hugo-base-dir "~/org-roam-garden/")
(setq org-hugo-section ".")
(setq org-hugo-front-matter-format "yaml")
(setq org-time-stamp-custom-formats '("%Y-%m-%d" . "%Y-%m-%d %H:%M"))

(setq org-garden-pub-dir (file-truename "~/org-roam-garden/content"))
(setq org-publish-timestamp-directory "~/org-roam-garden/.org-timestamps/")

(defun org-roam-update-meta (plist)
  "Update the roam metadata so the build will work"
  (org-roam-update-org-id-locations)
  (org-roam-db-sync))

(defun org-hugo-publish (plist org-file pub-dir)
  "Publish org file to hugo markdown"
  (with-current-buffer (find-file-noselect org-file)
    (org-hugo-export-wim-to-md :all-subtrees)
    (kill-buffer)))

(setq org-publish-list-skipped-files 'nil)
(setq org-publish-project-alist
  `(("org-roam-pages"
      :recursive t
      :base-extension "org"
      :base-directory "~/org-roam-garden/org-roam"
      :publishing-directory "~/org-roam-garden/content"
      :preparation-function org-roam-update-meta
      :publishing-function org-hugo-publish)
     ("org-pages"
       :recursive t
       :base-extension "org"
       :base-directory "~/org-roam-garden/pages"
       :publishing-directory "~/org-roam-garden/content"
       :publishing-function org-html-publish-to-html
       :body-only t)))

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

(org-publish-all)

