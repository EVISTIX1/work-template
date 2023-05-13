\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3 , xparse , l3keys2e}
\ProvidesExplClass{work-template}{2023/05/12}{0.1}{work template}

\msg_new:nnn { work-template } { engine-error }
  {
    Engine~ "#1"~ is~ not~ supported!\\\\
    This~ template~ requires~ either~ XeTeX~ or~ LuaTeX.
  }

\sys_if_engine_xetex:F
  {
    \sys_if_engine_luatex:F
      {
        \msg_fatal:nnx { work-template } { engine-error }
          { \c_sys_engine_str }
      }
  }

\sys_if_engine_xetex:T { \RequirePackage { etoolbox } }

%% 文档选项

\tl_new:N \g__wktemp_option_theme_tl

\clist_new:N \g__wktemp_option_to_class_clist
\clist_gset:Nn \g__wktemp_option_to_class_clist { a4paper, fontset = none }

\keys_define:nn { wktemp / option }
  {
    theme .choices:nn =
      { fancy, plain }
      { \tl_gset_eq:NN \g__wktemp_option_theme_tl \l_keys_choice_tl },
    theme .value_required:n = true,
    theme .initial:n        = fancy,

    zihao .choices:nn =
      { -4, 5 }
      { \clist_gput_right:Nx \g__wktemp_option_to_class_clist { zihao = \l_keys_choice_tl } },
  }
\ProcessKeysOptions { wktemp / option }

\PassOptionsToPackage { no-math } { fontspec }

\PassOptionsToClass { \g__wktemp_option_to_class_clist } { ctexart }
\LoadClass { ctexart }


\RequirePackage [ dvipsnames ] { xcolor }
\cs_new:Npn \wktemp_define_color:nnn #1#2#3
  { \definecolor { #1 } { #2 } { #3 } }

\tl_if_eq:NnT \g__wktemp_option_theme_tl { fancy }
  {
    \ctexset
      {
        part =
        {
          number     = \Roman{part},
        },
        section =
          {
            name        = { \S },
            format      = \Large \normalfont \centering,
            titleformat = \sffamily,
            nameformat  = \bfseries,
          },
        subsubsection/format += \fbox,
      }
  }


\RequirePackage { geometry }
\geometry {
  paperwidth = 210mm, paperheight = 297mm,
  top = 1.5cm, bottom = 2.5cm,
  left = 1.5cm, right = 1.5cm,
}

%% 字体设置

% 英文字体
\cs_new_protected:Npn \__wktemp_set_font_default: { }
%\cs_new_protected:Npn \__wktemp_set_font_times:
%  { \setmainfont { Times~ New~ Roman } }

% 中文字体
\cs_new_protected:Npn \__wktemp_set_cjk_font: {}
\cs_new_protected:Npn \__wktemp_set_cjk_main_font:nn #1#2
  {
    \setCJKmainfont { #1 } [ #2 ]
    \newCJKfontfamily [ zhsong ] \songti { #1 } [ #2 ]
  }
\cs_new_protected:Npn \__wktemp_set_cjk_sans_font:nn #1#2
  {
    \setCJKsansfont { #1 } [ #2 ]
    \newCJKfontfamily [ zhhei ] \heiti { #1 } [ #2 ]
  }
\cs_new_protected:Npn \__wktemp_set_cjk_font_kaishu:nn #1#2
  {
    \newCJKfontfamily [ zhkai ] \kaishu { #1 } [ #2 ]
  }
\cs_new_protected:Npn \__wktemp_set_cjk_mono_font:nn #1#2
  {
    \setCJKmonofont { #1 } [ #2 ]
    \newCJKfontfamily [ zhfs ] \fangsong { #1 } [ #2 ]
  }
\cs_new_protected:Npn \__wktemp_set_cjk_font_sourcehan:
  {
    \__wktemp_set_cjk_main_font:nn { Source~ Han~ Serif~ SC }
      {
        UprightFont    = *-Regular,
        BoldFont       = *-Bold,
        ItalicFont     = *-Regular,
        BoldItalicFont = *-Bold
      }
    \__wktemp_set_cjk_sans_font:nn { Source~ Han~ Sans~ SC }
      {
        UprightFont    = *-Regular,
        BoldFont       = *-Bold,
        ItalicFont     = *-Regular,
        BoldItalicFont = *-Bold
      }
    \__wktemp_set_cjk_font_kaishu:nn { FZKai-Z03S }
      {
        BoldFont       = *,
        ItalicFont     = *,
        BoldItalicFont = *
      }
    \__wktemp_set_cjk_mono_font:nn { FZFangSong-Z02S } 
      {
        BoldFont       = *,
        ItalicFont     = *,
        BoldItalicFont = *
      }
  }
\cs_new_protected:Npn \__wktemp_set_cjk_font_none: { }

\keys_define:nn { wktemp / style }
  {
    font .choices:nn =
      { times, default }
      { \cs_gset_eq:Nc \__wktemp_set_font: { __wktemp_set_font_ \l_keys_choice_tl : } },
    font .value_required:n = true,
    font .initial:n = default,

    cjk-font .choices:nn =
      { windows, none, sourcehan }
      { 
        \tl_if_in:NnTF \l_keys_choice_tl { sourcehan }
          {
            \cs_gset_eq:Nc \__wktemp_set_cjk_font: { __wktemp_set_cjk_font_ \l_keys_choice_tl : }
          }
          {
            \exp_args:Nx \ctexset { fontset = \l_keys_choice_tl } 
          }
      },
    cjk-font .value_required:n = true,
    % cjk-font .initial:n = ctex
  }
\hook_gset_rule:nnnn { begindocument/before } { . } { < } { xeCJK }
  % 在导言区末加载字体，保证其不被用户配置覆盖
\AtEndPreamble
{
  \RequirePackage [ warnings-off = { mathtools-colon, mathtools-overbracket }, bold-style = ISO ] 
    { unicode-math }
  \__wktemp_set_font:
  \__wktemp_set_cjk_font:
}

% 其他设置
\keys_define:nn { wktemp / style }
  {
    graphics-path .code:n = { \graphicspath { #1 } },

    punct .choices:nn =
      { quanjiao, banjiao, kaiming, CCT }
      { \tl_gset_eq:NN \g__wktemp_style_punct_tl \l_keys_choice_tl },
    punct .value_required:n = true,
    punct .initial:n        = quanjiao,
    punct .code:n = { \ctexset { punct = #1 } },

    today .choices:nn =
      { small, big, old }
      { \tl_gset_eq:NN \g__wktemp_style_today_tl \l_keys_choice_tl },
    today .value_required:n = true,
    today .initial:n        = small,
    today .code:n = { \ctexset { today = #1 } },

    enname .value_forbidden:n = true,
    enname .code:n = 
      {
        \ctexset
          {
            contentsname    = Contents,
            listfigurename  = List~ of~ Figures,
            listtablename   = List~ of~ Tables,
            figurename      = Figure,
            tablename       = Table,
            abstractname    = Abstract,
            indexname       = Index,
            appendixname    = Appendix,
            bibname         = References,
            proofname       = Proof,
            part/name       = { Part\space },
          }
      },

    fullwidth-stop .value_forbidden:n = true,
    fullwidth-stop .code:n =
      {
        \char_set_catcode_active:n { `。 }
        \char_set_active_eq:nN { `。 } ．
      }
  }

\keys_define:nn { wktemp }
  {
    style .meta:nn = { wktemp / style } { #1 },
  }

\NewDocumentCommand { \wktempset } { m }
  { \keys_set:nn { wktemp } {#1} }