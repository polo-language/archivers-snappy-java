# Created by: Radim Kolar <hsn@filez.com>
# $FreeBSD: head/archivers/snappy-java/Makefile 518482 2019-11-26 21:46:12Z jkim $
# Note to committers:
# With each version update, a new maven repository must be created and distributed
# so build is repeatable and cluster-safe.

PORTNAME=	snappy
PORTVERSION=	1.1.7.5
CATEGORIES=	archivers java
MASTER_SITES=	TODO:repo
PKGNAMESUFFIX=	java
DISTFILES+=	${PORTNAME}-${PKGNAMESUFFIX}-repository-${PORTVERSION}${EXTRACT_SUFX}:repo
EXTRACT_ONLY=	xerial-${PORTNAME}-${PKGNAMESUFFIX}-${PORTVERSION}_GH0${EXTRACT_SUFX} \
		${PORTNAME}-${PKGNAMESUFFIX}-repository-${PORTVERSION}${EXTRACT_SUFX}

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Fast compressor/decompressor library

LICENSE=	APACHE20

BROKEN_armv6=		fails to build: maven-assembly-plugin: Failed to retrieve numeric file attributes
BROKEN_armv7=		fails to build: maven-assembly-plugin: Failed to retrieve numeric file attributes
BROKEN_powerpc64=	fails to build: failed to execute goal org.apache.maven.plugins:maven-surefire-plugin:2.14.1:test

BUILD_DEPENDS=	sbt:devel/sbt

USES=		gmake
USE_JAVA=	yes
USE_LDCONFIG=	yes
MAKE_ARGS+=	CXX="${CXX}"
TEST_TARGET=	test
BITSHUFFLE_V=	0.3.2

USE_GITHUB=	yes
GH_ACCOUNT=	xerial \
		google:google \
		kiyo-masui:masui
GH_PROJECT=	snappy-java \
		snappy:google \
		bitshuffle:masui
GH_TAGNAME=	${PORTVERSION} \
		${PORTVERSION:R}:google \
		${BITSHUFFLE_V}:masui

PLIST_FILES=	${JAVAJARDIR}/snappy-java.jar lib/libsnappyjava.so

post-extract:
	@${MKDIR} ${WRKSRC}/target
	@${CP} ${DISTDIR}/google-snappy-${PORTVERSION:R}_GH0${EXTRACT_SUFX} ${WRKSRC}/target/snappy-${PORTVERSION:R}${EXTRACT_SUFX}
	@${CP} ${DISTDIR}/kiyo-masui-bitshuffle-${BITSHUFFLE_V}_GH0${EXTRACT_SUFX} ${WRKSRC}/target/bitshuffle-${BITSHUFFLE_V}${EXTRACT_SUFX}

do-build:
	cd ${WRKSRC} && ${SETENV} JAVA_HOME=${JAVA_HOME} ${MAKE_ENV} \
		${MAKE_CMD} ${MAKE_ARGS} SBT_IVY_HOME=${WRKDIR}/repository

do-test:
	cd ${WRKSRC} && ${SETENV} JAVA_HOME=${JAVA_HOME} ${MAKE_ENV} \
		${MAKE_CMD} ${MAKE_ARGS} SBT_IVY_HOME=${WRKDIR}/repository test

.include <bsd.port.pre.mk>

.if ${OPSYS} == FreeBSD && ${ARCH} == amd64
PLATFORM_DIR_SUFFIX=	FreeBSD-x86_64
.else
PLATFORM_DIR_SUFFIX=	Default
.endif

do-install:
	${INSTALL_DATA} ${WRKSRC}/target/snappy-java-${PORTVERSION}.jar \
		${STAGEDIR}${JAVAJARDIR}/snappy-java.jar
	${INSTALL_LIB} ${WRKSRC}/target/snappy-${PORTVERSION:R}-${PLATFORM_DIR_SUFFIX}/libsnappyjava.so \
		${STAGEDIR}${LOCALBASE}/lib

.include <bsd.port.post.mk>
