package com.hackerrank.eshopping.product.dashboard;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.nativex.hint.TypeHint;
import org.hibernate.dialect.PostgreSQL95Dialect;


@SpringBootApplication
@ComponentScan(basePackages = "com.hackerrank.eshopping")
@TypeHint(types = PostgreSQL95Dialect.class, typeNames = "org.hibernate.dialect.PostgreSQLDialect")
public class Application
{
    public static void main (String[] args)
    {
        SpringApplication.run (Application.class, args);
    }
}
