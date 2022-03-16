

FROM mcr.microsoft.com/windows:20H2


RUN curl.exe -o R-%R_VERSION%-win.exe https://cran.r-project.org/bin/windows/base/old/%R_VERSION%/R-%R_VERSION%-win.exe

RUN R-%R_VERSION%-win.exe /VERYSILENT /DIR="C:\\R\\"

RUN curl.exe -o Rtools.exe https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe

RUN Rtools.exe /TYPE=full /VERYSILENT -NoNewWindow -Wait

CMD [ "C:\\R\\bin\\R.exe", "--no-save" ]