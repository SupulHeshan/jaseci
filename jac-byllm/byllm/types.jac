"""Type definitions for LLM interactions.

This module defines the types used in the LLM interactions, including messages,
tools, and tool calls. It provides a structured way to represent messages,
tool calls, and tools that can be used in LLM requests and responses.
"""

import from __future__ {annotations}

import base64;
import mimetypes;
import os;
import from contextlib {suppress}
import from enum {StrEnum}
import from io {BytesIO}
import from typing {Callable, TypeAlias, get_type_hints}
import from PIL.Image {open as open_image}
import from litellm.types.utils {Message as LiteLLMMessage} 
import from pydantic {TypeAdapter} 
import from .schema {tool_to_schema} 

with entry{
    
# The message can be a jaclang defined message or what ever the llm
# returned object that was feed back to the llm as it was given (dict).
has MessageType: TypeAlias = "Message | LiteLLMMessage";
}


 """Enum for message roles in LLM interactions."""
enum MessageRole{
    SYSTEM = "system",
    USER = "user",
    ASSISTANT = "assistant",
    TOOL = "tool"
}

"""Message class for LLM interactions."""
obj Message{

    has role: MessageRole;
    has content: "str | list[Media]";
    
    """Convert the message to a dictionary."""
    def to_dict() -> dict[str, object]{
        if isinstance(self.content, str){
            return {
                "role": self.role.value,
                "content": self.content,
            };
        }
        media_contents = [];
        for media in self.content{
            media_contents.extend(media.to_dict());
        return {
            "role": self.role.value,
            "content": media_contents,
            };
        }
    }
}


    """Result of a tool call in LLM interactions."""
obj ToolCallResultMsg(Message){

    has tool_call_id: str;
    has name: str;  # Function name.

    """Post-initialization to set the role of the message."""
    def __post_init__() -> None{
        self.role = MessageRole.TOOL;  # Maybe this should be an assertion?
    }

     """Convert the tool call result message to a dictionary."""
    def to_dict() -> dict[str, object]{
        return {
            "role": self.role.value,
            "content": self.content,
            "tool_call_id": self.tool_call_id,
            "name": self.name,
        };
    }
}

 """Tool class for LLM interactions."""
obj Tool{

    has func: Callable;
    has description: str = "";
    has params_desc: dict[str, str] = None ; # type: ignore

    """Post-initialization to validate the function."""
    def __post_init__() -> None{ 
        annotations = get_type_hints(self.func);
        with suppress(Exception){
            self.func.__annotations__ = annotations;
        }

        self.description = Tool.get_func_description(self.func);
        
        if hasattr(self.func, "_jac_semstr_inner"){
            self.params_desc = self.func._jac_semstr_inner ; # type: ignore
        }else{
            self.params_desc = {name: str(type) for (name, type) in annotations.items()};
        }
    }

     """Call the tool function with the provided arguments."""
    def __call__(*args: list, **kwargs: dict) -> object{
        # If there is an error with the finish tool, we throw the exception.
        # Since it's the user's responsibility to handle it.
        if self.is_finish_tool(){
            return self.func(*args, **kwargs);
        }try{
            # TODO: Shoud I json serialize or this is fine?
            return self.func(*args, **kwargs);
        }except Exception as e{
            # For the LLM if the tool failed, it'll see the error message
            # and make decision based on that.
            return str(e);
        }
    }   

    """Return the name of the tool function."""
    def get_name() -> str{
        return self.func.__name__ ;
    }

    """Get the description of the function."""
    static
    def get_func_description(func: Callable) -> str{
        if hasattr(func, "_jac_semstr"){
            return func._jac_semstr ; # type: ignore
        }
        return func.__doc__ or func.__name__;
    }

     """Create a finish tool that returns the final output."""
    static
    def make_finish_tool(resp_type: type) -> Tool{

        def finish_tool(final_output: object) -> object{
            return TypeAdapter(resp_type).validate_python(final_output);
        }

        finish_tool.__annotations__["return"] = resp_type;
        finish_tool.__annotations__["final_output"] = resp_type;
        return Tool(
            func=finish_tool,
            description="This tool is used to finish the tool calls and return the final output.",
            params_desc={
                "final_output": "The final output of the tool calls.",
            },
        );
    }

    """Check if the tool is a finish tool."""
    def is_finish_tool() -> bool{
        return self.get_name() == "finish_tool";
    }
      """Return the JSON schema for the tool function."""
    def get_json_schema() -> dict[str, object]{
        return tool_to_schema(self.func, self.description, self.params_desc);
    }

     """Parse the arguments from JSON to the function's expected format."""
    def parse_arguments(args_json: dict) -> dict{
        args = {} ;

        annotations: dict = {};
        try{
            annotations = self.func.__annotations__;
        }except AttributeError{
            annotations = get_type_hints(self.func);
        }
        for (arg_name, arg_json) in args_json.items(){
            if arg_type := annotations.get(arg_name){
                args[arg_name] = TypeAdapter(arg_type).validate_python(arg_json);
            }
        return args;
        }
    }

}

"""Tool call class for LLM interactions."""
obj ToolCall{

    has call_id: str;
    has tool: Tool;
    has args: dict;

    """Call the tool with the provided arguments."""
    def __call__() -> ToolCallResultMsg{
        result = self.tool(**self.args);
        return ToolCallResultMsg(
            role = MessageRole.TOOL,
            content=str(result),
            tool_call_id=self.call_id,
            name=self.tool.get_name(),
        );
    }

     """Return the string representation of the tool call."""
    def __str__() -> str{
        params = ", ".join(f"{k}={v}" for (k, v) in self.args.items());
        return f"{self.tool.get_name()}({params})";
    }

    """Check if the tool is a finish tool."""
    def is_finish_call() -> bool{
        return self.tool.is_finish_tool();
    }

    """Get the output from the finish tool call."""
    def get_output() -> object{
        assert (
            self.is_finish_call()
        ); #This method should only be called for finish tools.
        return self.tool(**self.args);
    }

}

"""Mock tool call for testing purposes."""
obj MockToolCall{

    has tool: Callable;
    has args: dict;

    """Convert the mock tool call to a ToolCall."""
    def to_tool_call() -> ToolCall{
        return ToolCall(
            call_id="",  # Call ID is not used in mock calls.
            tool=Tool(self.tool),
            args=self.args,
        );
    }
}


"""Result of the completion from the LLM."""
obj CompletionResult{
    has output: object;
    has tool_calls: list[ToolCall];
}

# -----------------------------------------------------------------------------
# Media content types
# -----------------------------------------------------------------------------

"""Base class for message content."""
obj Media{

     """Convert the content to a dictionary."""
    def to_dict() -> list[dict]{
        raise NotImplementedError("Subclasses must implement this method.");
    }
}

"""Class representing text content in a message."""
obj Text(Media){
   
    has text: str;

    """Convert the text content to a dictionary."""
    def to_dict() -> list[dict]{
        return [{"type": "text", "text": self.text}];
    }
}

 """Class representing an image."""
obj Image(Media){
   
    has url: str;
    has mime_type: str | None = None;

  """Post-initialization to ensure the URL is a string."""
    def __post_init__() -> None{
        if self.url.startswith(("http://", "https://", "gs://")){
            self.url = self.url.strip();
        }else{
            if not os.path.exists(self.url){
                raise ValueError(f"Image file does not exist: {self.url}");
            image = open_image(self.url);
            }

            # python<3.13 mimetypes doesn't support `webp` format as it wasn't an IANA standard
            # until November 2024 (RFC-9649:  https://www.rfc-editor.org/rfc/rfc9649.html).
            if (image.format and image.format.lower()) == "webp"{
                self.mime_type = "image/webp";
            }else{
                self.mime_type = mimetypes.types_map.get(
                    "." + (image.format or "png").lower()
                );
            }
            with BytesIO() as buffer{
                image.save(buffer, format=image.format, quality=100);
                base64_image = base64.b64encode(buffer.getvalue()).decode("utf-8");
                self.url = f"data:{self.mime_type};base64,{base64_image}";
            }
        }
    }

 """Convert the image to a dictionary."""
    def to_dict() -> list[dict]{
        image_url = {"url": self.url};
        if self.mime_type{
            image_url["format"] = self.mime_type;
        }
        return [
            {
                "type": "image_url",
                "image_url": image_url,
            }
        ];
    }
}


# Ref: https://cookbook.openai.com/examples/gpt_with_vision_for_video_understanding
"""Class representing a video."""
obj Video(Media){

    has path: str;
    has fps: int = 1;
    has _base64frames: list[str] | None = None;

    """Post-initialization to ensure the path is a string."""
    def __post_init__() -> None{
        if not os.path.exists(self.path){
            raise ValueError(f"Video file does not exist: {self.path}");
        }
    }

    """Load video frames as base64-encoded images."""
    def load_frames() -> None{
        try{
            import cv2;
        }except ImportError{
            raise ImportError(
                "OpenCV is required to process video files."
                "Install `pip install byllm[video]` for video capabilities."
            );
        }

        self._base64frames = [];
        video = cv2.VideoCapture(self.path);
        total_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT));

        target_fps = self.fps;
        source_fps = video.get(cv2.CAP_PROP_FPS);
        frames_to_skip = (
            int(source_fps / target_fps) - 1 if target_fps < source_fps else 1
        );

        curr_frame = 0;
        while curr_frame < total_frames - 1{
            video.set(cv2.CAP_PROP_POS_FRAMES, curr_frame);
            (success, frame) = video.read();
            if not success{
                raise ValueError("Failed to read video frame.");
            }
            (_, buffer) = cv2.imencode(".jpg", frame);
            self._base64frames.append(base64.b64encode(buffer).decode("utf-8"));
            curr_frame += frames_to_skip;
            }
        }


      """Convert the video to a dictionary."""
    def to_dict() -> list[dict]{
      
        if self._base64frames is None{
            self.load_frames();
        }
        assert self._base64frames is not None;
        #Frames must be loaded before conversion.

        return [
            {
                "type": "image_url",
                "image_url": f"data:image/jpeg;base64,{frame}",
            }
            for frame in self._base64frames
        ];
    }
}








