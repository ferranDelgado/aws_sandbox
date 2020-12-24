/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package cat.aws.sandbox

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import java.io.InputStream
import java.io.OutputStream

val mapper = jacksonObjectMapper()

data class HandlerInput(val name: String)
data class ResponseBody(val message: String)
data class ResponseHeader(val myHeader: String = "my_value")
data class HandlerOutput(
    val statusCode: Int = 200,
    val body: String,
    val headers: ResponseHeader = ResponseHeader(),
    val isBase64Encoded: Boolean = false
)

/*
* var response = {
        "statusCode": 200,
        "headers": {
            "my_header": "my_value"
        },
        "body": JSON.stringify(responseBody),
        "isBase64Encoded": false
    };
* */
class App {
    val greeting: String
        get() {
            return "Hello world."
        }

    val anyResponse = HandlerOutput(body = "Hello world")

    fun handler(input: InputStream, output: OutputStream) {
        //val inputObj = mapper.readValue<HandlerInput>(input)
//        mapper.writeValue(output, HandlerOutput("Hello ${inputObj.name}"))
        mapper.writeValue(output, anyResponse)
    }
}

fun main(args: Array<String>) {
    println(mapper.writeValueAsString(App().anyResponse))
}
