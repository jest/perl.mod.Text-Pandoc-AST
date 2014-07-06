# NAME

Text::Pandoc::AST - Pandoc AST structure parsing and walking

# VERSION

version 0.001

# SYNOPSIS

As the software is in the pre-alpha state and everything can change, this is
just my imagination of the future API.

    use JSON 2.90;
    use Text::Pandoc::AST;

    my $jtree = JSON->new->utf8->decode($json_text);
    my $ast = Text::Pandoc::AST->from_json($jtree);
    
    # and possibly use it with Text::Pandoc::Filters
    
    my $filter = Text::Pandoc::Filters->new(\&filter_sub);
    my $modified_ast = $filter->walk($ast);

    print JSON->new->utf8->encode($modified_ast->to_json);

# DESCRIPTION

This class simplifies parsing JSON structure, as provided by `pandoc -t json` command. 

# SEE ALSO

[Text::Pandoc::Filters](https://metacpan.org/pod/Text::Pandoc::Filters) - for easy writing Pandoc tree modifying filters.

[http://johnmacfarlane.net/pandoc/scripting.html](http://johnmacfarlane.net/pandoc/scripting.html) - Pandoc filters docs.

[https://github.com/jgm/pandocfilters](https://github.com/jgm/pandocfilters) - pandocfilters Python project, by
which this module is inspired.

# AUTHOR

Przemyslaw Wesolek <jest@go.art.pl>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Przemyslaw Wesolek.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
