;; Tests assume a tab is represented by 4 spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(load-file "kotlin-mode.el")

;(require 'kotlin-mode)

(ert-deftest kotlin-mode--top-level-indent-test ()
  (with-temp-buffer
    (let ((text "package com.gregghz.emacs

import java.util.*
import foo.Bar
import bar.Bar as bBar
"))
      (insert text)
      (beginning-of-buffer)
      (kotlin-mode--indent-line)

      (should (equal text (buffer-string)))

      (next-line)
      (kotlin-mode--indent-line)
      (should (equal text (buffer-string)))

      (next-line)
      (kotlin-mode--indent-line)
      (should (equal text (buffer-string)))

      (next-line)
      (kotlin-mode--indent-line)
      (should (equal text (buffer-string)))

      (next-line)
      (kotlin-mode--indent-line)
      (should (equal text (buffer-string))))))

(ert-deftest kotlin-mode--single-level-indent-test ()
  (with-temp-buffer
    (let ((text "fun sum(a: Int, b: Int): Int {
return a + b
}"))

      (insert text)
      (beginning-of-buffer)
      (next-line)

      (kotlin-mode--indent-line)
      (should (equal (buffer-string) "fun sum(a: Int, b: Int): Int {
    return a + b
}")))))

(ert-deftest kotlin-mode--chained-methods ()
  (with-temp-buffer
    (let ((text "names.filter { it.empty }
.sortedBy { it }
.map { it.toUpperCase() }
.forEach { print(it) }"))

      (insert text)
      (beginning-of-buffer)

      (kotlin-mode--indent-line)

      (next-line)
      (kotlin-mode--indent-line)

      (next-line)
      (kotlin-mode--indent-line)

      (next-line)
      (kotlin-mode--indent-line)

      (should (equal (buffer-string) "names.filter { it.empty }
    .sortedBy { it }
    .map { it.toUpperCase() }
    .forEach { print(it) }")))))

(defun next-non-empty-line ()
  "Moves to the next non-empty line"
  (forward-line)
  (while (and (looking-at "^[ \t]*$") (not (eobp)))
    (forward-line)))

(ert-deftest kotlin-mode--sample-test ()
  (with-temp-buffer
      (insert-file-contents "test/sample.kt")
      (beginning-of-buffer)
      (while (not (eobp))
        (let ((expected-line (thing-at-point 'line)))

          ;; Remove existing indentation
          (beginning-of-line)
          (delete-region (point) (progn (skip-chars-forward " \t") (point)))

          ;; Indent the line
          (kotlin-mode--indent-line)

          ;; Check that the correct indentation is re-applied
          (should (equal expected-line (thing-at-point 'line)))

          ;; Go to the next non-empty line
          (next-non-empty-line)
          )
        )
      )
  )
