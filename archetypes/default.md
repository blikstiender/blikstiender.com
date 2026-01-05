---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
description:
slug: {{ .File.ContentBaseName }}
tags:
  -
date: {{ .Date | time.Format "2006-01-02" }}
---
# {{ replace .File.ContentBaseName "-" " " | title }}
*{{ .Date | time.Format "January 2, 2006" }}*

