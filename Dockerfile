FROM perl:5.32 as build

RUN apt-get update \
  && apt-get install -y unzip \
  && cpan File::Copy::Recursive File::Glob LWP::Simple TVDB::API Getopt::Long Switch WWW::TheMovieDB JSON::Parse XML::Simple

RUN curl -O https://master.dl.sourceforge.net/project/sorttv/SortTV1.38.zip \
  && unzip SortTV1.38.zip


FROM perl:5.32-slim as runtime

COPY --from=build /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=build /usr/local/bin /usr/local/bin/
COPY --from=build /sorttv /sorttv
COPY sorttv.conf /sorttv/sorttv.conf

ENV PATH="/sorttv/:${PATH}"

RUN chmod +x /sorttv/sorttv.pl && sed -i '1!b;s/usr/usr\/local/' /sorttv/sorttv.pl && mv /sorttv/sorttv.pl /sorttv/sorttv

ENTRYPOINT ["sorttv"]
