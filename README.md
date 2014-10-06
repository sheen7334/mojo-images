# NAME

Mojolicious::Plugin::Images - easy and powerful image manipulation for Mojolicious

# VERSION

version 0.001

# SYNOPSIS

    plugin 'Mojolicious::Plugin::Images', {
      big   => {},
      small => {
        from      => 'big',
        transform => [scale => {xpixels => 242, ypixels => 200, type => 'min'}]
      },
    #  thumb  => {from => 'small', transform => 'myclass#action'},
    #  thumb2 => {
    #    from      => 'small',
    #    transform => sub($t) { $t->image->scale(xpixels => 200) }
    #  },
    };

    # then in controller save an image ridiculously simple
    $c->images->big->upload('ID', 'image_or_other_name');

That's all. This code automatically installs lazy (on demand) resizing for images and
install valid static paths to serve images as static content. Check debug log to see
what paths to provide for nginx, for example.

# DESCRIPTION

This nifty and amazing plugin helps to orginize images in your application. It provides very simple but poweful features.
Can be used in small application with no coding (to generate thumbnails and so on) and
in poweful services which works a lot with images as well.

Plugin supports automaticaly calculation of static paths, on demand resizing (lazy), image protections and so on.
For example, if you'll decide to change a design, you can delete all you thumbnails and change the size. Plugin will
regenerate them when someone will need them on-the-fly.

Right now as you can see documentation is written "на отъебись" - to pass all tests only. It will be available soon if someone
will find that useful.

I've made a small but ready to run example. Check it out (see example directory)

By the way. I liked signatures feature so much, so I decided to made 5.20.0 as a depency. Sorry for that

# METHODS

## register a plugin

Registers a plugin with options. If options is omitted, plugin will try to load them from
configaration via b<plugin\_images> key

# AUTHOR

alexbyk <alexbyk@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
